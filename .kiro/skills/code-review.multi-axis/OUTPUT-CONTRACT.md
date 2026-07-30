# Sub-agent Output Contract

All review axis sub-agents MUST return output conforming to this contract. The orchestrator parses this structure to produce the final report.

## Response Structure

Every sub-agent response MUST be exactly one of these two forms:

### Form A: No findings

```
findings: 0
verdict: SHIP
```

Nothing else. No prose, no "everything looks good", no enumeration of passing checks.

### Form B: One or more findings

```
findings: <N>

[<confidence 1-10>] <finding line>
[<confidence 1-10>] <finding line>
...

verdict: <SHIP|FIX REQUIRED|NEEDS DISCUSSION>
```

### Form C: Auto-fixed issues (Style axis only)

Used when the Style axis ran automated formatters for pre-existing code style rules. FIXED items appear before findings. They do NOT count toward the finding total and do NOT affect the verdict.

```
FIXED: <file>. Ran <tool>. <N> formatting changes applied.
FIXED: <file>. Ran <tool>. <N> formatting changes applied.

findings: <0 or N>

[<confidence 1-10>] <finding line>
...

verdict: <SHIP|FIX REQUIRED|NEEDS DISCUSSION>
```

If only FIXED items and no findings:

```
FIXED: <file>. Ran <tool>. <N> formatting changes applied.

findings: 0
verdict: SHIP
```

## Finding Line Formats (per axis)

Each axis uses its own finding line format, but ALL findings MUST start with `[<confidence>]`:

**Security:**
```
[9] (Verified: all 3 callers pass user-controlled length) FAIL: Integer/size safety. No bounds check on `len` param. → Add POSIX_ENSURE(len <= MAX_RECORD_SIZE).
```

**Style:**
```
[8] src/auth.ts:L38. Bare `any` type on `decoded` variable. Cite: .kiro/steering/clean-code.md.
```

**Minimal:**
```
[9] src/auth.ts:L10: stale-doc. Docstring says "returns 403" but code returns 401. → Update docstring.
```

**Requirements:**
```
[8] MISSING: Pagination support. Cite: PRD section 3.2 "API must support limit/offset pagination".
```

**Quality:**
```
[8] tls/s2n_cipher_suites.c:L1083: type-mismatch. Binary search uses int for indices over a size_t-counted array; introduces narrowing assumption. → Use size_t throughout with half-open interval [low, high).
```

## Multi-line Findings

For complex findings, indent continuation lines with two spaces:

```
[9] FAIL: Attacker-controlled bypass. Query param bypasses auth.
  Detail: The `role` parameter from req.query is passed directly to the
  authorization middleware without validation. An attacker can set
  role=admin to escalate privileges. Fix: validate against an allowlist
  of permitted roles from the database.
```

The first line is always the one-line summary. The `Detail:` block is optional context for the orchestrator.

## Verdict Rules

- `verdict: SHIP` — no findings, OR all findings score < 8.
- `verdict: FIX REQUIRED` — at least one finding scores ≥ 8 AND represents a concrete problem that must be fixed.
- `verdict: NEEDS DISCUSSION` — findings score ≥ 8 but involve trade-offs requiring human judgment.

## Confidence Scoring

Every finding MUST include a confidence score (integer, 1-10). The orchestrator uses this score to sort findings into **Findings** (≥ 8, potentially blocking) and **Warnings** (< 8, non-blocking informational).

**Generic scale (applies to all axes):**

| Score | Meaning |
|-------|---------|
| **10** | Certain. Verifiable from the diff alone with no assumptions. |
| **9** | Near-certain. Clear evidence in the diff; would bet money on it. |
| **8** | Confident. Strong evidence, minor assumptions that are very likely true. |
| **7** | Probable. Likely correct but depends on one unverifiable assumption about the broader system. |
| **6** | Plausible. Reasonable concern but requires context the reviewer cannot see. |
| **5** | Possible. Could be an issue depending on deployment context or conventions not visible in the diff. |
| **4** | Speculative. More of a question than a finding. Worth the human glancing at. |
| **3** | Unlikely. Probably fine but technically not provably safe from the diff alone. |
| **2** | Very unlikely. Almost certainly not a real issue but noted for completeness. |
| **1** | Lowest confidence. Barely worth mentioning; reporting only because the checklist requires considering this category. |

Each axis sub-skill provides axis-specific calibration examples showing what each score level looks like for that domain. Refer to those for guidance on how to apply this generic scale to specific finding types.

## What NOT to Return

- Do NOT enumerate passing checks. No "PASS: item 1", "PASS: item 2" lists.
- Do NOT include preamble like "I've reviewed the diff and..."
- Do NOT include prose summaries after the verdict.
- Do NOT use any format other than the ones specified above.
