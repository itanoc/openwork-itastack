#!/usr/bin/env python3
"""Deterministic audit for personal memory.

Verifies that memory/index.md is in sync with the promoted memory files on disk.
(The candidate budget/staleness/dedup gating was removed with the move to the
ask-then-promote memory model; only the index audit remains.)
"""
import argparse
import re
import sys
from pathlib import Path

PROMOTED_DIRS = ["preferences", "docs", "voice", "email", "guides", "workflows", "decisions"]


def audit_index(memory_dir):
    """Verify that memory/index.md lists all promoted files accurately."""
    index_file = memory_dir / "index.md"
    if not index_file.exists():
        return {"status": "MISSING_INDEX"}

    content = index_file.read_text()

    # Extract backticked paths and markdown table links
    backticks = re.findall(r"`(memory/[^`]+)`", content)
    links = re.findall(r"\[([^\]]+)\]\(([^)]+)\)", content)
    indexed_paths = {path for _, path in links} | set(backticks)

    # Gather actual promoted files
    actual_files = []
    for d in PROMOTED_DIRS:
        p_dir = memory_dir / d
        if p_dir.exists():
            for f in p_dir.glob("*.md"):
                if f.name != ".gitkeep":
                    actual_files.append(f"memory/{d}/{f.name}")

    missing_from_index = [f for f in actual_files if f not in indexed_paths]
    stale_in_index = [
        p for p in indexed_paths
        if p.startswith("memory/") and not (memory_dir.parent / p).exists()
    ]

    return {
        "missing_from_index": missing_from_index,
        "stale_in_index": stale_in_index,
        "valid": len(missing_from_index) == 0 and len(stale_in_index) == 0,
    }


def main():
    ap = argparse.ArgumentParser(description="Audit personal memory index alignment with files.")
    ap.add_argument("--memory", default="memory", help="Memory directory root (default: memory)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("audit", help="Audit index alignment with files")

    args = ap.parse_args()
    mem_path = Path(args.memory)

    if args.cmd == "audit":
        res = audit_index(mem_path)
        if res.get("status") == "MISSING_INDEX":
            print("Alert: The memory index file (memory/index.md) was not found.")
            sys.exit(1)
        if not res.get("valid", True):
            print("Looks like my memory files need a little organizing. Ok if I tidy things up?")
            sys.exit(4)
        print("Success: Memory index is fully in sync with your files.")
        sys.exit(0)


if __name__ == "__main__":
    main()
