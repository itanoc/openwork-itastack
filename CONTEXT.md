# ITAStack OpenWork — Shared Language

Shared terms for OpenWork memory, ticket research, and reusable technician guidance in this workspace.

## Language

**Ticket Guide**:
A redacted reusable troubleshooting instruction saved in personal memory under `memory/guides/` for future Halo ticket research.
_Avoid_: raw ticket memory, client-specific ticket notes

**Company KB (CKB)**:
Read-only company knowledge base of prose facts and policy, queried via `itastack_ckb_query`. Used in ticket research for tech-stack scoping and process/policy framing — never as the technical fix.
_Avoid_: treating CKB as a Ticket Guide, treating CKB as the source of the fix

## Relationships

- A **Ticket Guide** may include problem pattern, product/vendor, redacted symptoms/errors, diagnostic checks, safe fix steps, verification steps, risk or rollback notes, and source links.
- A **Ticket Guide** must not include client names, user emails, hostnames, IPs, tenant IDs, raw logs, passwords, secrets, or full ticket text.
- A **Ticket Guide** save prompt is a one- or two-sentence friendly footnote; the agent drafts proposed saved content only after the technician approves the prompt.
- A **Ticket Guide** lookup may use Halo ticket-derived context locally after ticket fetch; saved guide content and public web searches still avoid private client or user details.
- A **Ticket Guide** stays personal/local by default; team sharing requires a separate explicit promotion process.
- The **Company KB (CKB)** is distinct from a **Ticket Guide**: CKB is shared read-only company data with no save gate; a Ticket Guide is personal, redacted, and saved through an approval gate. In ticket research the CKB is queried once, after Ticket Guides and before web research.
