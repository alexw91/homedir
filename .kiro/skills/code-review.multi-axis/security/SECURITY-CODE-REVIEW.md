# Security Code Review (Sub-skill)

Review the diff as a security auditor. Your job is to find exploitable weaknesses or incomplete fixes, not theoretical concerns. Think like an attacker reviewing a proposed change.

## Core Question

**"Can an attacker exploit this change — through a bypass, a missing check, a leaked secret, or an incomplete fix?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P show <sha>` to inspect committed changes. Use `read_file` and `grep_search` to verify findings against surrounding code per the Verification Protocol below.

**Remote mode:** The diff is provided inline in your prompt. Use the platform-specific file-read recipe for surrounding context if needed.

## Findings Catalog

1. `incomplete-fix:` - **Does this close all variants?** Does the change handle every path to the dangerous state, or just the obvious one? An attacker will find the path you didn't guard. If the fix only addresses one of several routes to the vulnerable state, the vulnerability remains exploitable through the unguarded paths. Verdict ≥ 8: `FIX REQUIRED`.

2. `fail-open:` - **Does this fail closed?** If the new check encounters an unexpected condition, does it deny/error or does it fall through to the unsafe path? Security checks must deny on ambiguity. If an exception, unexpected type, or malformed input causes the check to be skipped rather than to reject, the attacker controls the bypass. Verdict ≥ 8: `FIX REQUIRED`.

3. `check-removed:` - **Has any validation been weakened?** Has any pre-existing validation been weakened, moved, or deleted — even if it seems redundant? Defense-in-depth means every layer validates independently. Removing a check creates a single-point-of-failure at whatever other layer was supposed to handle it. Verdict ≥ 8: `FIX REQUIRED`.

4. `error-swallowed:` - **Do error returns propagate?** Do all new error conditions propagate to the caller? No silent swallowing, no continue-after-error. A swallowed error in security code means the system proceeds in a state it should have rejected, potentially with attacker-controlled values in supposedly-validated fields. Verdict ≥ 8: `FIX REQUIRED`.

5. `bypass:` - **Can attacker-controlled input skip validation?** Can any attacker-controlled input cause the new validation to be skipped entirely? Look for early returns before the check, conditional paths that bypass the guard, or input values that cause the check function itself to short-circuit. Verdict ≥ 8: `FIX REQUIRED`.

6. `timing:` - **Are there timing side-channels?** Does the validation path leak information through timing differences (early return on specific values, variable-time comparison)? If an attacker can distinguish "wrong first byte" from "wrong last byte" by response time, they can brute-force the secret byte-by-byte. Use constant-time comparison for secrets. Verdict ≥ 8: `FIX REQUIRED`.

7. `integer-safety:` - **Are sizes/lengths checked for overflow?** Are arithmetic operations on attacker-influenced sizes/lengths checked for overflow, underflow, or truncation before use? An unchecked length that wraps around can cause buffer overflows, under-allocations, or infinite loops. Add bounds checks before arithmetic on attacker-controlled sizes. Verdict ≥ 8: `FIX REQUIRED`.

8. `concurrency:` - **Is this safe under concurrent access?** If the changed code path is reachable from multiple threads or async contexts, is the change still correct under concurrent access? TOCTOU races, unsynchronized shared state, and non-atomic check-then-act sequences are exploitable. Verdict ≥ 8: `FIX REQUIRED`.

9. `same-class:` - **Does the same bug class exist elsewhere?** Does the same bug class exist on adjacent code paths not touched by this diff? List any found — these are informational findings that suggest the fix is incomplete at the systemic level. Verdict ≥ 8: `NEEDS DISCUSSION`.

10. `weak-test:` - **Are tests adversarial?** Do the new tests attempt to violate the invariants being enforced, or do they only test the happy path? Security tests must include inputs designed to bypass the new check — malformed values, boundary lengths, null bytes, encoding tricks. Happy-path-only tests give false confidence. Verdict ≥ 8: `NEEDS DISCUSSION`.

11. `leaked-secret:` - **Is sensitive context exposed?** Do the commit message, code comments, test names, or string literals expose secrets, internal URLs, API keys, credentials, or sensitive architectural details that shouldn't be in version control? Once committed, secrets are in git history forever. Verdict ≥ 8: `FIX REQUIRED`.

12. `symptom-fix:` - **Root cause or symptom?** Does this fix address the root cause, or does it patch one instance of a deeper problem? Is there a compiler warning, linter rule, type system constraint, or CI check that could make this entire class of bug impossible to introduce again? If yes and the fix doesn't add one, a permanent automated guardrail is better than a point fix that relies on future developers remembering. Verdict ≥ 8: `FIX REQUIRED`.

## Verification Protocol

Every candidate finding MUST be verified before reporting, regardless of initial confidence. Do not report findings based solely on what the diff shows. Verify against the surrounding codebase to drive confidence decisively up or down.

### Process

1. **Identify candidate findings.** Walk the catalog against the diff. For each potential finding, note the catalog item, code location, and initial concern.

2. **Verify each candidate.** For every candidate:
   - Read the full function containing the flagged code (not just the diff hunk).
   - If the concern involves a value flowing from callers: grep for call sites and read at least 2. Does every caller validate the input before reaching this code path?
   - If the concern involves a return value consumed elsewhere: read the consuming function's precondition checks or error handling.
   - If the concern involves "same class elsewhere" (item 9): grep for the pattern and verify at least one concrete instance exists.
   - If the concern is trivially provable from the diff alone (e.g., a secret hardcoded in a string literal, an error path with no return statement), no external code needs to be read.

3. **Assign final confidence and disposition.** After verification:
   - **Concern resolved** — surrounding code proves the dangerous state is unreachable. Drop the finding. Do not report it.
   - **Concern confirmed** — verification found no mitigation, or found that the dangerous state IS reachable. Report at final confidence (typically ≥ 8).
   - **Concern inconclusive** — you checked the relevant code but cannot definitively confirm or deny. Report the finding with the evidence you gathered.

### Verification tags

Every reported finding MUST include a parenthetical verification tag after the confidence score:

- `(Verified: <what confirmed it>)` — you checked surrounding code and it confirmed the vulnerability.
- `(Verified: visible in diff)` — the finding is trivially obvious from the diff alone and no surrounding code was needed.
- `(Inconclusive: <what you checked and why it didn't resolve>)` — you attempted verification but couldn't close the loop.

### Cost management

- Read only the minimum needed to confirm/deny. One function body + 2 call sites is usually sufficient.
- If the finding is trivially obvious from the diff, tag it `(Verified: visible in diff)` and move on.
- If you've read 3+ files and still can't resolve the concern, stop and tag `(Inconclusive: ...)`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly. Report only findings that survived verification — do not enumerate passing checks or resolved candidates.

Finding line format for this axis:

```
[<confidence 1-10>] (<verification tag>) <tag> <what's wrong>. → <suggested fix>.
```

For complex findings:

```
[<confidence>] (<verification tag>) <tag> <summary>.
  Detail: <multi-line explanation of the attack path, why it works, and the specific fix needed>
```

Examples:

```
[9] (Verified: all 3 callers pass user-controlled length) integer-safety: No bounds check on `len` param. → Add POSIX_ENSURE(len <= MAX_RECORD_SIZE).
[7] (Inconclusive: traced 2/4 call sites; remaining 2 are in generated code) incomplete-fix: Guard only covers direct callers. → Audit generated callers.
[10] (Verified: visible in diff) leaked-secret: AWS account ID in test fixture string literal. → Replace with placeholder.
```

## Confidence Calibration (Security axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Reproducible exploit with specific inputs. "Send this TLS record, get unauthorized access."
- **9:** Clear vulnerability visible in the diff. Missing bounds check on attacker-controlled length field.
- **8:** Very likely exploitable. Error path silently continues instead of returning failure.
- **6-7:** Likely an issue but depends on whether the code path is reachable from untrusted input. Report it.
- **4-5:** Concerns about test/internal code that might become externally reachable. Worth noting.
- **2-3:** Theoretical concern with no concrete path from untrusted input to the dangerous state.
- **1:** Barely a concern. Reporting only for checklist completeness.

## Rules

- The diff is your starting point. The Verification Protocol is MANDATORY for every candidate finding. Use read_file and grep_search to inspect surrounding code.
- Do NOT flag defense-in-depth as redundant. Two checks for the same thing at different layers is intentional.
- Do NOT flag "theoretical" issues without a concrete attack path. "An attacker could theoretically..." is not a finding. "Send X, get Y" is.
- Severity hierarchy: Security > Readability > Correctness > Performance. Never recommend removing a security check for readability or performance.
- For test code and internal utilities, still review thoroughly but assign lower confidence (4-6) to findings that depend on the code being reachable from an external attack surface.
- Aim for one-line-per-finding brevity, but expand if the finding is genuinely complex and a one-liner would lose the attack path.
- The Findings Catalog is not exhaustive. If you identify a security concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `timing-oracle (new):`, `privilege-escalation (new):`). The same output format, confidence scoring, and verdict rules apply.

## Boundaries

- **vs Quality:** If a finding involves a type mismatch or fragile assumption that is also exploitable by an attacker, it belongs here (Security takes priority). Quality catches the same class of issue when the impact is correctness/maintainability rather than exploitability.
- **vs Clean:** Security checks are NOT redundant — defense-in-depth is intentional. Never flag a security validation as `redundant:` even if another layer also checks it.
