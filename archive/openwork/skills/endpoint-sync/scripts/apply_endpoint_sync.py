#!/usr/bin/env python3
"""apply_endpoint_sync.py — Verified local apply for OpenWork endpoint sync.

Performs the safety-critical half of the endpoint-sync workflow locally so the
agent does not have to generate large inline Python each run. The agent still
talks to the ITAStack MCP config service for status, bundle URL, and telemetry;
this script does the download (optional), verification, extraction, allowlist
enforcement, add/update-only apply, atomic state write, and a compact
changed-path summary on stdout.

Standard library only. No third-party dependencies.

Inputs:
  --manifest      Path to a JSON file containing the manifest object from the
                  status response (the inner `manifest` object, OR the full
                  status response — the script accepts either and finds
                  `files[]`, `config_version`/`latest_version`, `bundle_sha256`,
                  `channel`).
  --bundle-url    Short-lived URL to download the bundle (.tar.gz). XOR --bundle-path.
  --bundle-path   Path to an already-downloaded bundle (.tar.gz).         XOR --bundle-url.
  --apply-root    Workspace root to apply into. Defaults to current directory.
  --channel       Channel label written to state. Defaults to manifest channel
                  or "stable".
  --dry-run       Verify everything and print the summary, but do not write
                  files or state.

Usage:
  python apply_endpoint_sync.py --manifest status.json --bundle-url "https://..."
  python apply_endpoint_sync.py --manifest status.json --bundle-path /tmp/b.tar.gz
  python apply_endpoint_sync.py --manifest status.json --bundle-path /tmp/b.tar.gz --dry-run

Output (stdout): a single compact JSON object, for example:
  {
    "result": "success",
    "version": "2026.06.22.1922",
    "channel": "stable",
    "bundle_sha256": "....",
    "applied_count": 70,
    "added": ["..."],
    "updated": ["..."],
    "unchanged_count": 68,
    "state_path": ".openwork/state/itastack-config-installed.json"
  }
On failure it prints {"result": "failed", "error_class": "...", "message": "..."}
and exits non-zero. error_class/message are safe scalars (no absolute paths,
secrets, or URLs) intended for MCP telemetry.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import os
import posixpath
import re
import shutil
import sys
import tarfile
import tempfile
import urllib.request

STATE_REL = ".openwork/state/itastack-config-installed.json"
# Backups of files this run overwrites or deletes are written here, under the
# excluded .openwork/state/ prefix, so they can never be re-ingested as sync
# input. Each run gets its own timestamped subdir; original relative paths are
# preserved beneath it so a revert is a straight copy back.
BACKUP_ROOT_REL = ".openwork/state/backups"
ARCHIVE_ROOT_REL = ".openwork/state/archives"

# Allowlist (POSIX relative globs are not used; we match by prefix/exact below).
ALLOWED_EXACT = {
    "AGENTS.md",
    "memory/README.md",
    "memory/TEMPLATES.md",
}
ALLOWED_PREFIXES = (
    ".agents/skills/",
    ".opencode/agents/",
    ".opencode/plugins/",
    ".opencode/workflows/",
    ".opencode/commands/",
)
# memory/*/.gitkeep — exactly one path segment between memory/ and /.gitkeep.
_MEMORY_GITKEEP = re.compile(r"^memory/[^/]+/\.gitkeep$")

# Private/local paths that must never be applied. Checked before allowlist so a
# manifest cannot smuggle an excluded path in via an allowed prefix.
EXCLUDED_EXACT = {
    "opencode.json",
    "opencode.jsonc",
}
EXCLUDED_PREFIXES = (
    ".openwork/state/",
    "artifacts/",
    ".handoff/",
    ".onboarding/",
    ".issues/",
    "youtube/",
    "prototypes/",
    "teaching/",
)
_HEX64 = re.compile(r"^[0-9a-f]{64}$")
_SAFE_MODES = {"0644", "0755"}


class ApplyError(Exception):
    def __init__(self, error_class: str, message: str):
        super().__init__(message)
        self.error_class = error_class
        self.message = message


def _is_excluded(path: str) -> bool:
    if path in EXCLUDED_EXACT:
        return True
    if path.startswith(".env"):
        return True
    for pre in EXCLUDED_PREFIXES:
        if path.startswith(pre):
            return True
    # memory/** is excluded except the explicit scaffold paths handled in _is_allowed.
    if path.startswith("memory/") and path not in ALLOWED_EXACT and not _MEMORY_GITKEEP.match(path):
        return True
    return False


def _is_allowed(path: str) -> bool:
    if path in ALLOWED_EXACT:
        return True
    if _MEMORY_GITKEEP.match(path):
        return True
    for pre in ALLOWED_PREFIXES:
        if path.startswith(pre):
            return True
    return False


def _validate_relpath(path: str) -> str:
    """Normalize and validate a manifest/tar path. Returns the safe rel path."""
    if not path or not isinstance(path, str):
        raise ApplyError("manifest_path_invalid", "empty or non-string path")
    if "\\" in path:
        raise ApplyError("manifest_path_invalid", "backslash in path")
    if path.startswith("/") or (len(path) > 1 and path[1] == ":"):
        raise ApplyError("manifest_path_invalid", "absolute path")
    norm = posixpath.normpath(path)
    if norm != path:
        raise ApplyError("manifest_path_invalid", "non-normalized path")
    if norm == ".." or norm.startswith("../") or "/../" in norm:
        raise ApplyError("manifest_path_invalid", "path traversal")
    if _is_excluded(norm):
        raise ApplyError("manifest_path_excluded", "private/local path not allowed")
    if not _is_allowed(norm):
        raise ApplyError("manifest_path_not_allowlisted", "path outside allowlist")
    return norm


def _sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _load_manifest(manifest_path: str) -> dict:
    try:
        with open(manifest_path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, ValueError):
        raise ApplyError("manifest_unreadable", "manifest file unreadable or not JSON")
    # Accept either the full status response or the inner manifest object.
    manifest = data.get("manifest") if isinstance(data.get("manifest"), dict) else data
    files = manifest.get("files")
    if not isinstance(files, list) or not files:
        raise ApplyError("manifest_invalid", "manifest has no files[]")
    version = (
        manifest.get("config_version")
        or data.get("latest_version")
        or manifest.get("version")
    )
    if not version:
        raise ApplyError("manifest_invalid", "manifest missing version")
    bundle_sha = data.get("bundle_sha256") or manifest.get("bundle_sha256")
    channel = manifest.get("channel") or data.get("channel") or "stable"
    manifest_sha = data.get("manifest_sha256") or manifest.get("manifest_sha256")
    return {
        "files": files,
        "version": version,
        "bundle_sha256": bundle_sha,
        "channel": channel,
        "manifest_sha256": manifest_sha,
    }


def _manifest_from_bundle(bundle_path: str) -> dict:
    """Build a validated {relpath: {sha256, mode, size}} map from a verified tar.

    Used by --from-bundle mode. The bundle's overall sha256 has already been
    checked against the server's signed bundle_sha256 by the caller, so the tar
    contents are exactly what the server published. Every entry still passes the
    same allowlist / path / mode safety checks as a JSON manifest, and per-file
    sha256 is computed from the verified bytes.
    """
    out: dict[str, dict] = {}
    try:
        tf = tarfile.open(bundle_path, "r:*")
    except (tarfile.TarError, OSError):
        raise ApplyError("bundle_extract_failed", "bundle is not a readable tar")
    with tf:
        for member in tf.getmembers():
            name = member.name
            if name in (".", "./"):
                continue
            name = name[2:] if name.startswith("./") else name
            if member.isdir():
                continue
            if not member.isfile() or member.issym() or member.islnk():
                raise ApplyError("unsafe_bundle_entry", "non-regular tar entry")
            rel = _validate_relpath(name)
            mode = "0%o" % (member.mode & 0o777)
            if mode not in _SAFE_MODES:
                # Bundles are built with 0644; normalize anything else to 0644
                # rather than failing, since the bundle sha is already trusted.
                mode = "0644"
            src = tf.extractfile(member)
            if src is None:
                raise ApplyError("unsafe_bundle_entry", "unreadable tar entry")
            h = hashlib.sha256()
            while True:
                chunk = src.read(1024 * 1024)
                if not chunk:
                    break
                h.update(chunk)
            if rel in out:
                raise ApplyError("manifest_invalid", "duplicate path in bundle")
            out[rel] = {"sha256": h.hexdigest(), "mode": mode, "size": member.size}
    if not out:
        raise ApplyError("manifest_invalid", "bundle has no allowlisted files")
    return out


def _validate_files(files: list) -> dict:
    """Validate every manifest entry. Returns {relpath: {sha256, mode, size}}."""
    out: dict[str, dict] = {}
    for entry in files:
        if not isinstance(entry, dict):
            raise ApplyError("manifest_invalid", "file entry not an object")
        rel = _validate_relpath(entry.get("path", ""))
        sha = entry.get("sha256", "")
        if not isinstance(sha, str) or not _HEX64.match(sha):
            raise ApplyError("manifest_hash_invalid", "sha256 not lowercase 64-hex")
        mode = entry.get("mode")
        if mode is not None and str(mode) not in _SAFE_MODES:
            raise ApplyError("manifest_mode_invalid", "unsafe file mode")
        if rel in out:
            raise ApplyError("manifest_invalid", "duplicate path in manifest")
        out[rel] = {"sha256": sha, "mode": str(mode) if mode is not None else None,
                    "size": entry.get("size")}
    return out


def _read_state(apply_root: str) -> dict:
    state_path = os.path.join(apply_root, STATE_REL)
    try:
        with open(state_path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return {}


def _download(url: str, dest: str) -> None:
    # Only http(s). The URL is short-lived and integrity is enforced by sha256.
    if not (url.startswith("https://") or url.startswith("http://")):
        raise ApplyError("bundle_download_failed", "unsupported bundle url scheme")
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "openwork-endpoint-sync"})
        with urllib.request.urlopen(req, timeout=120) as resp, open(dest, "wb") as out:
            while True:
                chunk = resp.read(1024 * 1024)
                if not chunk:
                    break
                out.write(chunk)
    except Exception:
        raise ApplyError("bundle_download_failed", "bundle download failed")


def _safe_extract(bundle_path: str, manifest_files: dict, tmpdir: str) -> dict:
    """Extract + verify tar into tmpdir. Returns {relpath: extracted_abs_path}."""
    extracted: dict[str, str] = {}
    try:
        tf = tarfile.open(bundle_path, "r:*")
    except (tarfile.TarError, OSError):
        raise ApplyError("bundle_extract_failed", "bundle is not a readable tar")
    with tf:
        for member in tf.getmembers():
            name = member.name
            if name in (".", "./"):
                continue
            name = name[2:] if name.startswith("./") else name
            if member.isdir():
                continue
            if not member.isfile():
                raise ApplyError("unsafe_bundle_entry", "non-regular tar entry")
            if member.issym() or member.islnk():
                raise ApplyError("unsafe_bundle_entry", "symlink or hardlink in bundle")
            rel = _validate_relpath(name)
            if rel not in manifest_files:
                raise ApplyError("unsafe_bundle_entry", "bundle entry not in manifest")
            target = os.path.join(tmpdir, rel)
            if not os.path.realpath(target).startswith(os.path.realpath(tmpdir) + os.sep):
                raise ApplyError("unsafe_bundle_entry", "extract path escapes temp dir")
            os.makedirs(os.path.dirname(target), exist_ok=True)
            src = tf.extractfile(member)
            if src is None:
                raise ApplyError("unsafe_bundle_entry", "unreadable tar entry")
            with src, open(target, "wb") as out:
                while True:
                    chunk = src.read(1024 * 1024)
                    if not chunk:
                        break
                    out.write(chunk)
            actual = _sha256_file(target)
            if actual != manifest_files[rel]["sha256"]:
                raise ApplyError("file_hash_mismatch", "extracted file hash mismatch")
            extracted[rel] = target
    missing = set(manifest_files) - set(extracted)
    if missing:
        raise ApplyError("bundle_incomplete", "manifest file missing from bundle")
    return extracted


def _target_is_safe(target: str) -> None:
    if os.path.islink(target):
        raise ApplyError("unsafe_target", "target is a symlink")
    if os.path.exists(target):
        if os.path.isdir(target):
            raise ApplyError("unsafe_target", "target is a directory")
        st = os.lstat(target)
        if st.st_nlink > 1:
            raise ApplyError("unsafe_target", "target is a hardlink")
        if not os.path.isfile(target):
            raise ApplyError("unsafe_target", "target is not a regular file")


class _Backup:
    """Lazily-created, run-scoped backup directory under .openwork/state/backups.

    Files are copied here (preserving their relative path) immediately before
    this run overwrites or deletes them, so any apply is reversible. The
    directory is created only when the first file actually needs backing up, so
    a no-op or dry run leaves no empty backup dirs behind. Backup failures never
    abort the sync — the copy is best-effort and recorded in `errors`.
    """

    def __init__(self, apply_root: str, version: str, dry_run: bool):
        self.apply_root = apply_root
        self.dry_run = dry_run
        stamp = _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        safe_version = re.sub(r"[^A-Za-z0-9._-]", "_", str(version or "unknown"))
        self.rel = posixpath.join(BACKUP_ROOT_REL, "%s-%s" % (safe_version, stamp))
        self.abs = os.path.join(apply_root, *self.rel.split("/"))
        self.saved: list[str] = []
        self.errors: list[str] = []
        self._made = False

    def _ensure_dir(self) -> None:
        if not self._made:
            os.makedirs(self.abs, exist_ok=True)
            self._made = True

    def save(self, rel: str, target: str) -> None:
        """Copy target (an existing regular file) into the backup dir under rel.

        Best-effort: on dry runs, when the file is absent, or on any I/O error,
        it records state and returns without raising so the sync proceeds.
        """
        if self.dry_run:
            self.saved.append(rel)
            return
        if not os.path.isfile(target) or os.path.islink(target):
            return
        try:
            self._ensure_dir()
            dest = os.path.join(self.abs, *rel.split("/"))
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copy2(target, dest)
            self.saved.append(rel)
        except OSError:
            # A backup that cannot be written must not block the config update;
            # record it and continue.
            self.errors.append(rel)


def _apply(extracted: dict, manifest_files: dict, apply_root: str,
           prev_hashes: dict, dry_run: bool, backup: "_Backup") -> dict:
    added, updated, unchanged = [], [], []
    for rel in sorted(manifest_files):
        target = os.path.join(apply_root, rel)
        rp = os.path.realpath(target)
        if not rp.startswith(os.path.realpath(apply_root) + os.sep) and rp != os.path.realpath(apply_root):
            raise ApplyError("unsafe_target", "target escapes apply root")
        _target_is_safe(target)
        new_hash = manifest_files[rel]["sha256"]
        old_hash = prev_hashes.get(rel)
        target_exists = os.path.isfile(target)
        if not target_exists or old_hash is None and not target_exists:
            status = "added"
        else:
            current = _sha256_file(target) if target_exists else None
            if current == new_hash:
                status = "unchanged"
            elif target_exists:
                status = "updated"
            else:
                status = "added"
        if status == "unchanged":
            unchanged.append(rel)
            continue
        if status == "updated":
            # Back up the current content before it is overwritten. Adds have no
            # prior content to preserve.
            backup.save(rel, target)
        if not dry_run:
            os.makedirs(os.path.dirname(target), exist_ok=True)
            tmp = target + ".tmp-sync"
            with open(extracted[rel], "rb") as s, open(tmp, "wb") as d:
                d.write(s.read())
            mode = manifest_files[rel]["mode"]
            if mode in _SAFE_MODES:
                os.chmod(tmp, int(mode, 8))
            os.replace(tmp, target)
        (added if status == "added" else updated).append(rel)
    return {"added": added, "updated": updated, "unchanged": unchanged}


MAINTENANCE_REL = ".agents/skills/endpoint-sync/maintenance.json"
# id must start and end alphanumeric; no leading/trailing dots/dashes, so values
# like ".." can never appear. Used only as a state dedup key, never as a path.
_MAINT_ID = re.compile(r"^[A-Za-z0-9](?:[A-Za-z0-9._-]{0,126}[A-Za-z0-9])?$")


class _MaintSkip(Exception):
    """Raised internally to skip a single maintenance op without failing sync."""

    def __init__(self, reason: str):
        super().__init__(reason)
        self.reason = reason


def _maint_target_path(apply_root: str, rel: str) -> str:
    """Validate a maintenance path against the same allowlist as sync, and
    resolve it safely inside apply_root. Skips (never fails sync) on anything
    not allowlisted, traversal, escape, or symlink."""
    try:
        safe = _validate_relpath(rel)  # raises ApplyError on traversal/excluded/non-allowlisted
    except ApplyError as e:
        raise _MaintSkip(e.message)
    target = os.path.join(apply_root, safe)
    rp = os.path.realpath(target)
    root_rp = os.path.realpath(apply_root)
    if not (rp == root_rp or rp.startswith(root_rp + os.sep)):
        raise _MaintSkip("path escapes apply root")
    if os.path.islink(target):
        raise _MaintSkip("target is a symlink")
    return safe, target


def _archive_unshipped_skills(apply_root: str, manifest_paths: set, version: str,
                              dry_run: bool, backup: "_Backup") -> int:
    """Move unshipped regular skill files into the local state archive."""
    skills_rel = ".agents/skills"
    skills_root = os.path.join(apply_root, *skills_rel.split("/"))
    if not os.path.isdir(skills_root) or os.path.islink(skills_root):
        return 0
    stamp = _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    safe_version = re.sub(r"[^A-Za-z0-9._-]", "_", str(version or "unknown"))
    archive_root = os.path.join(apply_root, *ARCHIVE_ROOT_REL.split("/"),
                                "%s-%s" % (safe_version, stamp))
    archive_parent = os.path.dirname(archive_root)
    if os.path.islink(archive_parent):
        raise _MaintSkip("archive destination is a symlink")
    archived = 0
    for dirpath, dirnames, filenames in os.walk(skills_root, followlinks=False):
        dirnames[:] = [name for name in dirnames
                        if not os.path.islink(os.path.join(dirpath, name))]
        for name in filenames:
            src = os.path.join(dirpath, name)
            if os.path.islink(src) or not os.path.isfile(src):
                continue
            rel = os.path.relpath(src, apply_root).replace(os.sep, "/")
            if rel in manifest_paths:
                continue
            _maint_target_path(apply_root, rel)
            dest = os.path.join(archive_root, *rel.split("/"))
            if not os.path.realpath(os.path.dirname(dest)).startswith(
                    os.path.realpath(archive_root) + os.sep):
                raise _MaintSkip("archive destination escapes archive root")
            backup.save(rel, src)
            if not dry_run:
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                os.replace(src, dest)
            archived += 1
    return archived


def _run_maintenance(apply_root: str, extract_dir: str, done_ids: set,
                      manifest_files: dict, version: str, dry_run: bool,
                      backup: "_Backup") -> dict:
    """Run one-time, idempotent maintenance ops from the VERIFIED bundle's
    maintenance.json (delete/move on allowlisted config paths only).

    Designed for unattended office endpoints: it NEVER asks a question and NEVER
    fails the sync. Any malformed or unsafe op (or a conflict with a path the
    current bundle still ships) is skipped and reported in `skipped`, not raised.
    The file is read from the extracted+verified bundle, never the working tree,
    so its contents are integrity-anchored by bundle_sha256.

    Each op has a stable string `id`; an op whose id is already in state is
    skipped silently so every op runs at most once per endpoint. Returns
    {"ran": [...], "skipped": [...], "newly_done": [...]}.
    """
    maint_src = os.path.join(extract_dir, MAINTENANCE_REL)
    ran, skipped, newly_done = [], [], []
    if not os.path.isfile(maint_src):
        return {"ran": ran, "skipped": skipped, "newly_done": newly_done}
    try:
        with open(maint_src, "r", encoding="utf-8") as fh:
            doc = json.load(fh)
        ops = doc.get("operations")
    except (OSError, ValueError):
        # Unreadable maintenance file must not block config sync.
        return {"ran": ran, "skipped": [{"id": None, "reason": "maintenance.json unreadable"}],
                "newly_done": newly_done}
    if not isinstance(ops, list):
        return {"ran": ran, "skipped": [{"id": None, "reason": "no operations[]"}],
                "newly_done": newly_done}

    manifest_paths = set(manifest_files or {})
    for op in ops:
        op_id = op.get("id") if isinstance(op, dict) else None
        try:
            if not isinstance(op, dict):
                raise _MaintSkip("operation is not an object")
            if not isinstance(op_id, str) or not _MAINT_ID.match(op_id):
                raise _MaintSkip("operation id missing or invalid")
            if op_id in done_ids:
                continue  # already applied on this endpoint; idempotent skip
            kind = op.get("op")
            if kind == "delete":
                rel, target = _maint_target_path(apply_root, op.get("path", ""))
                # Conflict guard (#1): never delete a path the current bundle
                # still ships, or sync would re-add it every run.
                if rel in manifest_paths:
                    raise _MaintSkip("delete target is shipped by the current bundle")
                if os.path.exists(target):
                    if os.path.isdir(target):
                        raise _MaintSkip("delete target is a directory")
                    backup.save(rel, target)  # preserve before removal
                    if not dry_run:
                        os.remove(target)
                # Missing target => already satisfied (idempotent).
            elif kind == "move":
                src_rel, src = _maint_target_path(apply_root, op.get("from", ""))
                dst_rel, dst = _maint_target_path(apply_root, op.get("to", ""))
                if src_rel in manifest_paths:
                    raise _MaintSkip("move source is shipped by the current bundle")
                if os.path.exists(src):
                    if os.path.isdir(src):
                        raise _MaintSkip("move source is a directory")
                    if os.path.exists(dst):
                        raise _MaintSkip("move destination exists")
                    backup.save(src_rel, src)  # preserve source before it moves
                    if not dry_run:
                        os.makedirs(os.path.dirname(dst), exist_ok=True)
                        os.replace(src, dst)
                # Source missing => assume already moved (idempotent).
            elif kind == "archive_unshipped_skills":
                archived = _archive_unshipped_skills(apply_root, manifest_paths,
                                                      version, dry_run, backup)
                op = {**op, "archived_count": archived}
            else:
                raise _MaintSkip("unknown op kind")
        except _MaintSkip as s:
            skipped.append({"id": op_id, "reason": s.reason})
            continue
        ran.append({"id": op_id, "op": op.get("op")})
        newly_done.append(op_id)
    return {"ran": ran, "skipped": skipped, "newly_done": newly_done}


def _write_state(apply_root: str, mf: dict, manifest_files: dict, dry_run: bool,
                 maint_done: list | None = None) -> str:
    state = {
        "channel": mf["channel"],
        "version": mf["version"],
        "bundle_sha256": mf["bundle_sha256"],
        "manifest_sha256": mf.get("manifest_sha256"),
        "installed_at": _dt.datetime.now(_dt.timezone.utc).isoformat(),
        "verification": "mcp-authenticated-sha256",
        "file_hashes": {rel: manifest_files[rel]["sha256"] for rel in sorted(manifest_files)},
    }
    if maint_done is not None:
        state["maintenance_done"] = sorted(maint_done)
    state_path = os.path.join(apply_root, STATE_REL)
    if not dry_run:
        os.makedirs(os.path.dirname(state_path), exist_ok=True)
        tmp = state_path + ".tmp-sync"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(state, fh, indent=2, sort_keys=True)
        os.replace(tmp, state_path)
    return STATE_REL


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Verified local apply for OpenWork endpoint sync.")
    # --manifest is the classic path. --from-bundle is the small-model-safe path:
    # the helper derives the file list from the sha-pinned bundle itself, so the
    # agent only has to pass a few scalars it can copy reliably (bundle url, sha,
    # version) instead of faithfully writing a ~150-file manifest JSON.
    ap.add_argument("--manifest", help="Path to status/manifest JSON (classic mode)")
    ap.add_argument("--from-bundle", action="store_true",
                    help="Derive the manifest from the sha-pinned bundle (no manifest JSON needed)")
    ap.add_argument("--bundle-sha256", help="Expected bundle sha256 (required with --from-bundle)")
    ap.add_argument("--version", dest="version", help="Config version (required with --from-bundle)")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--bundle-url")
    g.add_argument("--bundle-path")
    ap.add_argument("--apply-root", default=os.getcwd())
    ap.add_argument("--channel", default=None)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args(argv)

    apply_root = os.path.abspath(args.apply_root)
    try:
        from_bundle = args.from_bundle
        if not from_bundle and not args.manifest:
            raise ApplyError("usage_error", "provide --manifest or --from-bundle")
        if from_bundle:
            if not args.bundle_sha256 or not _HEX64.match(args.bundle_sha256):
                raise ApplyError("usage_error", "--from-bundle requires a valid --bundle-sha256")
            if not args.version:
                raise ApplyError("usage_error", "--from-bundle requires --version")
            mf = {
                "files": None,
                "version": args.version,
                "bundle_sha256": args.bundle_sha256,
                "channel": args.channel or "stable",
                "manifest_sha256": None,
            }
            manifest_files = None  # derived from the verified bundle below
        else:
            mf = _load_manifest(args.manifest)
            if args.channel:
                mf["channel"] = args.channel
            manifest_files = _validate_files(mf["files"])

        prev_state = _read_state(apply_root)
        prev_hashes = prev_state.get("file_hashes", {}) if isinstance(prev_state, dict) else {}
        prev_maint = prev_state.get("maintenance_done", []) if isinstance(prev_state, dict) else []
        done_ids = set(prev_maint) if isinstance(prev_maint, list) else set()

        with tempfile.TemporaryDirectory(prefix="ow-endpoint-sync-") as tmp:
            if args.bundle_url:
                bundle_path = os.path.join(tmp, "bundle.tar.gz")
                _download(args.bundle_url, bundle_path)
            else:
                bundle_path = args.bundle_path
                if not os.path.isfile(bundle_path):
                    raise ApplyError("bundle_download_failed", "bundle path not found")

            # bundle_sha256 is mandatory in --from-bundle mode and is the sole
            # integrity anchor there, so it is always checked.
            if mf["bundle_sha256"]:
                actual = _sha256_file(bundle_path)
                if actual != mf["bundle_sha256"]:
                    raise ApplyError("bundle_hash_mismatch", "bundle sha256 mismatch")
            elif from_bundle:
                raise ApplyError("usage_error", "--from-bundle requires --bundle-sha256")

            if from_bundle:
                manifest_files = _manifest_from_bundle(bundle_path)
                mf["files"] = list(manifest_files)

            extract_dir = os.path.join(tmp, "extract")
            os.makedirs(extract_dir, exist_ok=True)
            extracted = _safe_extract(bundle_path, manifest_files, extract_dir)
            backup = _Backup(apply_root, mf["version"], args.dry_run)
            result = _apply(extracted, manifest_files, apply_root, prev_hashes,
                            args.dry_run, backup)

            # Persist the successful file-sync state BEFORE maintenance, so a
            # maintenance hiccup can never discard a good config update.
            state_rel = _write_state(apply_root, mf, manifest_files, args.dry_run,
                                     maint_done=sorted(done_ids))

            # One-time maintenance (delete/move) from the verified bundle, run
            # after the file apply and recorded by id so each fires once.
            # Maintenance NEVER fails the sync: bad ops are skipped and reported,
            # not raised. Office endpoints get no prompts and no blocked updates.
            maint = _run_maintenance(apply_root, extract_dir, done_ids,
                                     manifest_files, mf["version"], args.dry_run, backup)
            if maint["newly_done"]:
                all_done = sorted(done_ids | set(maint["newly_done"]))
                state_rel = _write_state(apply_root, mf, manifest_files, args.dry_run,
                                         maint_done=all_done)

        summary = {
            "result": "success",
            "version": mf["version"],
            "channel": mf["channel"],
            "bundle_sha256": mf["bundle_sha256"],
            "applied_count": len(result["added"]) + len(result["updated"]),
            "added": result["added"],
            "updated": result["updated"],
            "unchanged_count": len(result["unchanged"]),
            "maintenance_ran": maint["ran"],
            "maintenance_skipped": maint["skipped"],
            "state_path": state_rel,
            "backup_path": (backup.rel if backup.saved else None),
            "backup_count": len(backup.saved),
            "backup_errors": backup.errors,
            "dry_run": bool(args.dry_run),
        }
        print(json.dumps(summary, separators=(",", ":")))
        return 0
    except ApplyError as e:
        print(json.dumps({"result": "failed", "error_class": e.error_class,
                          "message": e.message}, separators=(",", ":")))
        return 1
    except Exception:
        print(json.dumps({"result": "failed", "error_class": "unexpected_error",
                          "message": "unexpected failure during apply"},
                         separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
