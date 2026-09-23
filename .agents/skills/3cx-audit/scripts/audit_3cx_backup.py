#!/usr/bin/env python3
"""
3CX backup auditor.

Takes a 3CX backup (.zip / extracted folder), parses the configuration database
(`*Db.xml`) plus the `DbTables/*.csv` exports, and writes a comprehensive
Markdown audit report describing the system.

Usage:
    python3 audit_3cx_backup.py <backup.zip|extracted_dir> [--out report.md] [--workdir DIR]

Notes:
- The original backup is never modified. Archives are extracted to a temp/work dir.
- Nothing is redacted in the report (passwords, PINs, auth IDs are included as-is),
  per skill design. Treat the output as sensitive.
- Pure stdlib (zipfile, tarfile, csv, xml.etree). Mac/Linux portable.
"""
import argparse
import csv
import os
import sys
import tarfile
import tempfile
import zipfile
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from datetime import datetime, timezone

csv.field_size_limit(10_000_000)


# ----------------------------- extraction --------------------------------

def extract_backup(path, workdir):
    """Return a directory containing the extracted backup tree."""
    if os.path.isdir(path):
        return path
    os.makedirs(workdir, exist_ok=True)
    dest = os.path.join(workdir, "extracted")
    os.makedirs(dest, exist_ok=True)
    lower = path.lower()
    if lower.endswith(".zip"):
        with zipfile.ZipFile(path) as z:
            z.extractall(dest)
    elif lower.endswith((".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz2")):
        with tarfile.open(path) as t:
            t.extractall(dest)
    else:
        raise SystemExit(f"Unsupported archive type: {path}")
    return dest


def find_file(root, predicate):
    for dirpath, _dirs, files in os.walk(root):
        for f in files:
            if predicate(f):
                return os.path.join(dirpath, f)
    return None


def find_db_xml(root):
    return find_file(root, lambda f: f.endswith("Db.xml"))


def read_csv(root, name):
    """Read DbTables/<name>.csv -> list of dict rows. Empty list if missing."""
    path = find_file(root, lambda f: f == name)
    if not path:
        return []
    rows = []
    with open(path, newline="", encoding="utf-8", errors="replace") as fh:
        reader = csv.reader(fh)
        try:
            header = next(reader)
        except StopIteration:
            return []
        for r in reader:
            rows.append(dict(zip(header, r)))
    return rows


# ----------------------------- helpers -----------------------------------

def txt(el, tag, default=""):
    if el is None:
        return default
    v = el.findtext(tag)
    return v.strip() if v else default


TOLL_FREE_PREFIXES = ("800", "833", "844", "855", "866", "877", "888")


def is_toll_free(number):
    """True if a number is a North American toll-free DID."""
    digits = "".join(c for c in (number or "") if c.isdigit())
    if len(digits) == 11 and digits.startswith("1"):
        digits = digits[1:]
    return len(digits) == 10 and digits[:3] in TOLL_FREE_PREFIXES


def md_table(headers, rows):
    out = ["| " + " | ".join(headers) + " |",
           "| " + " | ".join("---" for _ in headers) + " |"]
    for r in rows:
        cells = [str(c).replace("\n", " ").replace("|", "\\|") if c is not None else "" for c in r]
        out.append("| " + " | ".join(cells) + " |")
    return "\n".join(out)


def dest_str(dest_el):
    """Render a ForwardDestination/<To> + <Internal DN=> into readable text."""
    if dest_el is None:
        return ""
    to = dest_el.findtext("To") or ""
    internal = dest_el.find("Internal")
    dn = internal.get("DN") if internal is not None else None
    num = dest_el.findtext("Number") or ""
    parts = [to]
    if dn:
        parts.append(f"DN {dn}")
    if num:
        parts.append(num)
    return " ".join(p for p in parts if p).strip()


# ----------------------------- main parse ---------------------------------

def build_report(root_dir, source_label):
    db_xml = find_db_xml(root_dir)
    if not db_xml:
        raise SystemExit("Could not find *Db.xml in the backup.")
    tree = ET.parse(db_xml)
    root = tree.getroot()

    hdr = root.find("header")
    lic = root.find("license")
    fqdn = root.find("fqdn")
    mail = root.find("mailSettings")
    gen = root.find("generalSettings")
    tenant = root.find("Tenants/Tenant")
    dn = tenant.find("DN") if tenant is not None else None

    L = []
    w = L.append

    # ---- header ----
    w(f"# 3CX System Audit")
    w("")
    w(f"- **Source:** `{source_label}`")
    w(f"- **Report generated:** {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}")
    w(f"- **3CX version:** {txt(hdr,'version')}")
    w(f"- **Backup taken:** {txt(hdr,'Date')}")
    w("")

    # ---- system overview ----
    w("## System Overview")
    w("")
    company = txt(lic, "company")
    overview = [
        ("Company", company),
        ("License key", txt(lic, "licensekey")),
        ("License contact", txt(lic, "contact")),
        ("License email", txt(lic, "email")),
        ("Reseller", txt(lic, "reseller")),
        ("Admin email", txt(lic, "adminemail")),
        ("External FQDN", txt(fqdn, "externalFqdn")),
        ("Internal FQDN", txt(fqdn, "internalFqdn")),
        ("Domain code", txt(fqdn, "domainCode")),
        ("Recording path", txt(gen, "recordingPath")),
        ("Backup path", txt(gen, "backupPath")),
    ]
    w(md_table(["Field", "Value"], [(k, v) for k, v in overview if v]))
    w("")

    # ---- mail settings ----
    if mail is not None:
        w("## Mail / SMTP Settings")
        w("")
        mrows = [
            ("Server host", txt(mail, "mailServerHost")),
            ("Server port", txt(mail, "mailServerPort")),
            ("From address", txt(mail, "mailFromAddress")),
            ("Auth user", txt(mail, "mailServerUser")),
            ("Password", txt(mail, "mailServerPassword")),
            ("Use TLS", txt(mail, "mailServerUseTLS")),
        ]
        w(md_table(["Field", "Value"], [(k, v) for k, v in mrows if v != ""]))
        w("")

    # ---- DN inventory counts ----
    counts = Counter(k.tag for k in dn) if dn is not None else Counter()
    extensions = dn.findall("Extension") if dn is not None else []
    queues = dn.findall("Queue") if dn is not None else []
    ivrs = dn.findall("IVR") if dn is not None else []
    ext_lines = dn.findall("ExternalLine") if dn is not None else []
    ring_groups = dn.findall("RingGroup") if dn is not None else []
    enabled_ext = sum(1 for e in extensions if txt(e, "Enabled") == "True")

    w("## Inventory Summary")
    w("")
    inv = [
        ("Extensions", len(extensions), f"{enabled_ext} enabled"),
        ("Ring groups", len(ring_groups), ""),
        ("Queues", len(queues), ""),
        ("IVRs / digital receptionists", len(ivrs), ""),
        ("Trunks / external lines", len(ext_lines), ""),
        ("Park extensions", counts.get("ParkExtension", 0), ""),
        ("Fax extensions", counts.get("FaxExtension", 0), ""),
        ("Conference extensions", counts.get("ConferencePlaceExtension", 0), ""),
    ]
    w(md_table(["Object", "Count", "Notes"], inv))
    w("")

    # ---- groups ----
    groups = tenant.findall("Groups/Group") if tenant is not None else []
    if groups:
        w("## Groups")
        w("")
        grows = []
        for g in groups:
            grows.append((txt(g, "Name"), txt(g, "Number"),
                          len(g.findall("Members/Member")) or txt(g, "MemberCount")))
        w(md_table(["Name", "Number", "Members"], grows))
        w("")

    # ---- extensions ----
    if extensions:
        w("## Extensions")
        w("")
        erows = []
        for e in sorted(extensions, key=lambda x: txt(x, "Number")):
            erows.append((
                txt(e, "Number"),
                (txt(e, "FirstName") + " " + txt(e, "LastName")).strip(),
                txt(e, "EmailAddress"),
                txt(e, "Enabled"),
                txt(e, "VMEnabled"),
                txt(e, "RecordCalls"),
                txt(e, "AuthID"),
                txt(e, "AuthPassword"),
                txt(e, "VMPIN"),
            ))
        w(md_table(["Ext", "Name", "Email", "Enabled", "VM", "Rec",
                    "AuthID", "AuthPassword", "VM PIN"], erows))
        w("")

    # ---- trunks ----
    gateways = {g.findtext("Name"): g for g in root.findall("Gateways/Gateway")}
    providers = {p.findtext("Name"): p for p in root.findall("Gateways/VoipProvider")}
    if ext_lines:
        w("## Trunks / VoIP Providers")
        w("")
        for line in ext_lines:
            gw_name = txt(line, "Gateway")
            gw = gateways.get(gw_name)
            if gw is None:
                gw = providers.get(gw_name)
            host = txt(gw, "Host") if gw is not None else ""
            gtype = txt(gw, "Type") if gw is not None else ""
            w(f"### Trunk {txt(line,'Number')} — {gw_name}")
            w("")
            trows = [
                ("Direction", txt(line, "Direction")),
                ("Simultaneous calls", txt(line, "SimultaneousCalls")),
                ("Auth ID", txt(line, "AuthID")),
                ("Auth password", txt(line, "AuthPassword")),
                ("Gateway type", gtype),
                ("SIP host", host),
                ("SIP port", txt(gw, "Port") if gw is not None else ""),
                ("Registration", txt(gw, "RequireRegistrationFor") if gw is not None else ""),
            ]
            w(md_table(["Field", "Value"], [(k, v) for k, v in trows if v != ""]))
            w("")
            # Routing rules keyed by DID/pattern
            route_by_did = {}
            for r in line.findall("RoutingRules/ExternalLineRule"):
                data = txt(r, "Data")
                if not data:
                    continue
                oh = dest_str(r.find("ForwardDestinations/OfficeHoursDestination"))
                ooh = dest_str(r.find("ForwardDestinations/OutOfOfficeHoursDestination"))
                route_by_did[data] = (oh, ooh)

            # Authoritative provisioned DID list from the DIDNumbers field
            did_field = txt(line, "DIDNumbers")
            provisioned = [d.strip() for d in did_field.split(",") if d.strip()]
            # Include any DID that only appears as a routing rule
            for d in route_by_did:
                if d not in provisioned:
                    provisioned.append(d)

            if provisioned:
                rows = []
                for d in provisioned:
                    oh, ooh = route_by_did.get(d, ("", ""))
                    rows.append((d, "Toll-free" if is_toll_free(d) else "DID",
                                 oh, ooh))
                tf_count = sum(1 for d in provisioned if is_toll_free(d))
                w(f"**DIDs on this trunk ({len(provisioned)}; {tf_count} toll-free):**")
                w("")
                w(md_table(["Number", "Type", "Office hours dest",
                            "Out-of-hours dest"], rows))
                w("")

    # ---- queues ----
    if queues:
        w("## Queues")
        w("")
        for q in queues:
            members = q.findall("Members/Member")
            w(f"### Queue {txt(q,'Number')} — {txt(q,'Name')}")
            w("")
            qrows = [
                ("Polling strategy", txt(q, "PollingStrategy")),
                ("Ring timeout", txt(q, "RingTimeout")),
                ("Master timeout", txt(q, "MasterTimeout")),
                ("Announce position", txt(q, "AnnounceQueuePosition")),
                ("Intro file", txt(q, "IntroFile")),
                ("On-hold file", txt(q, "OnHoldFile")),
                ("Agents", str(len(members))),
            ]
            w(md_table(["Field", "Value"], [(k, v) for k, v in qrows if v != ""]))
            w("")
            if members:
                agent_list = ", ".join(m.get("DN", "") for m in members)
                w(f"**Agents:** {agent_list}")
                w("")

    # ---- IVRs ----
    if ivrs:
        w("## IVRs / Digital Receptionists")
        w("")
        irows = []
        for iv in ivrs:
            irows.append((txt(iv, "Number"), txt(iv, "Name"),
                          txt(iv, "PromptFilename"), txt(iv, "Timeout")))
        w(md_table(["Number", "Name", "Prompt", "Timeout"], irows))
        w("")

    # ---- outbound rules ----
    out_rules = tenant.findall("OutboundRules/OutboundRule") if tenant is not None else []
    if out_rules:
        w("## Outbound Rules")
        w("")
        orows = []
        for o in out_rules:
            orows.append((
                txt(o, "Name") or txt(o, "RuleName"),
                txt(o, "Prefix"),
                txt(o, "NumberLengthRanges") or txt(o, "Digits"),
            ))
        w(md_table(["Name", "Prefix", "Digits/Length"], orows))
        w("")

    # ---- DbTables: call history / cdr counts ----
    w("## Data Tables (from DbTables)")
    w("")
    table_facts = []
    for fname, label in [
        ("myphone_callhistory_v14.csv", "Call history records"),
        ("cdroutput.csv", "CDR output rows"),
        ("cdrbilling.csv", "CDR billing rows"),
        ("callcent_queuecalls.csv", "Queue call records"),
        ("callcent_ag_dropped_calls.csv", "Queue dropped-call records"),
        ("cl_calls.csv", "Call log calls"),
        ("recordings.csv", "Recording entries"),
        ("s_voicemail.csv", "Voicemail records"),
        ("audit_log.csv", "Audit log entries"),
    ]:
        rows = read_csv(root_dir, fname)
        if rows or find_file(root_dir, lambda f: f == fname):
            table_facts.append((label, len(rows), fname))
    if table_facts:
        w(md_table(["Data", "Rows", "Source file"], table_facts))
        w("")

    # ---- certificates ----
    cert_dir = None
    for dirpath, dirs, _files in os.walk(root_dir):
        if os.path.basename(dirpath) == "Certificates":
            cert_dir = dirpath
            break
    if cert_dir:
        certs = sorted(os.listdir(cert_dir))
        w("## Certificates")
        w("")
        w(f"{len(certs)} certificate file(s) present in backup:")
        w("")
        for c in certs:
            w(f"- `{c}`")
        w("")

    # ---- key parameters ----
    params = root.findall("Parameters/Parameter")
    if params:
        interesting = {
            "PARK", "UNPARK", "ECHOTEST", "FAXOVEREMAILGATEWAY",
            "DIALCODECONFGATEWAY", "OPERATOR", "VMAILGATEWAY",
        }
        prows = []
        for p in params:
            name = txt(p, "Name")
            if name in interesting:
                prows.append((name, txt(p, "Description"), txt(p, "Value")))
        if prows:
            w("## Notable System Parameters")
            w("")
            w(md_table(["Name", "Description", "Value"], prows))
            w("")

    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("backup", help="Path to 3CX backup .zip or extracted folder")
    ap.add_argument("--out", help="Output markdown path")
    ap.add_argument("--workdir", help="Working dir for extraction")
    args = ap.parse_args()

    backup = os.path.abspath(os.path.expanduser(args.backup))
    if not os.path.exists(backup):
        raise SystemExit(f"Backup not found: {backup}")

    workdir = args.workdir or os.path.join(
        tempfile.gettempdir(), "3cx-audit",
        datetime.now().strftime("%Y%m%d-%H%M%S"))
    root_dir = extract_backup(backup, workdir)
    report = build_report(root_dir, os.path.basename(backup))

    out = args.out
    if not out:
        out = os.path.join(os.getcwd(), "3cx-audit-report.md")
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(report)
    print(f"Report written to: {out}")
    print(f"Extracted to: {root_dir}")


if __name__ == "__main__":
    main()
