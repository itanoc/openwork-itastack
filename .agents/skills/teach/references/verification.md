# Teaching-claim verification

Verify one falsifiable claim before presenting it as fact.

## When required

- Empirical, historical, bibliographic, API, product, or tool claims.
- Named theorems, identities, or standard facts the teacher cannot reconstruct confidently.
- Any important statement otherwise carried by tone rather than evidence.

Skip external search only when the claim can be derived in-session and an external citation is unnecessary. Label it derived, not sourced.

## Method

1. Rewrite the claim as one falsifiable sentence.
2. Make one focused search for primary or authoritative sources. Open the strongest one or two results; do not cite a result that was not opened and do not repeatedly broaden the search.
3. Record what each source establishes and any scope condition such as version, edition, dimension, or jurisdiction.
4. Return one verdict: `confirmed`, `qualified`, `contradicted`, or `unknown`.
5. Provide one sentence the teacher may now say, carrying any required hedge.

If web access is unavailable and the claim cannot be derived, return `unknown`. Never invent papers, quotations, page numbers, or URLs.

## Output

    ## Claim
    <falsifiable sentence>

    ## Verdict
    confirmed | qualified | contradicted | unknown

    ## Sources
    - <title and URL> — <what it establishes>

    ## Teach as
    <one sentence with necessary qualification>

When a teaching session is active, append the compact verdict and citations to its session file. Verification is complete when the verdict is evidence-backed or explicitly `unknown`.
