# Minimal Code Review (Sub-skill)

Review the diff for unnecessary complexity. The change's best outcome is getting shorter.

## Core Question

**"Can this change be made shorter without losing correctness or clarity?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P show <sha>` to inspect committed changes and `git -P diff HEAD` to inspect uncommitted changes. Focus on hunks where line count or abstraction depth raises suspicion.

**Remote mode:** The diff is provided inline in your prompt. Work from the inline diff and CR/PR metadata provided.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `accidental-export (new):`, `stale-import (new):`). The same output format, confidence scoring, and verdict rules apply.

1. `delete:` - **Is this code alive?** Dead code, unused flexibility, speculative feature. No callers, no consumers, no path that reaches it. The replacement is nothing — delete it. Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `stdlib:` - **Does the standard library already do this?** Hand-rolled implementation of something the standard library or framework ships with the exact same signature and behavior. Name the stdlib function that replaces it. Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `yagni:` - **Is there a second consumer?** Abstraction with one implementation, config nobody sets, layer with one caller. If no second consumer exists or is on the roadmap, the indirection is waste. Remove the layer and inline. Verdict ≥ 8: `NEEDS DISCUSSION`.

4. `shrink:` - **Can this be shorter?** Same logic expressed in fewer lines without losing clarity. Show the shorter form. This is about mechanical compression — same semantics, fewer tokens. If the fix requires rethinking the approach, it belongs to Quality, not here. Verdict ≥ 8: `NEEDS DISCUSSION`.

5. `redundant:` - **Is this already done elsewhere?** Validation already performed by a caller or callee, OR a capability the codebase already provides (retry logic, parsing, formatting, etc.) being reimplemented locally. Remove the duplicate and use the existing mechanism. Exception: security checks at trust boundaries are NOT redundant — defense-in-depth is intentional. Verdict ≥ 8: `NEEDS DISCUSSION`.

6. `new-file:` - **Does this file already exist under another name?** New file created when an existing file covers the same component. Example: creating a new test file when the repo's naming convention maps to an existing test file (e.g., changes to `src/foo.c` should go in `tests/foo_test.c`). Also applies to non-test files: creating `utils2.ts` when `utils.ts` already handles the same domain. Only flag if the convention-matching file exists. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `mixed-scope:` - **Are unrelated changes bundled?** Diff bundles unrelated changes — a bug fix mixed with a refactor, or a feature change mixed with formatting cleanup. Each logical change should be a separate commit or PR so reviewers can evaluate correctness independently. Does not apply to changes that are naturally cohesive (a feature plus its tests, a refactor that must touch multiple files atomically). Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `identifier-fidelity:` - **Is the canonical form preserved?** An identifier (key, name, path, ARN, URI) is available in its fully qualified canonical form but the code constructs an abbreviated or partial representation. Preserve identifier fidelity: use the canonical form everywhere — in labels, logs, error messages, test names, and diagnostics. The test: can a reader copy the value from the output, paste it into a codebase search, and land on exactly one definition? If not, the representation is insufficiently canonical. Only flag when the consumer accepts the full form and no format constraint forces abbreviation. Verdict ≥ 8: `NEEDS DISCUSSION`.

9. `stale-doc:` - **Does the documentation match the new behavior?** Comment, docstring, or header documentation that describes the old (now-changed) behavior. The code changed but the docs didn't follow. Update to reflect the new semantics. Verdict ≥ 8: `FIX REQUIRED`.

Note: Test quality checks (including `no-gate:`) have moved to the Test Quality axis (`test-quality/TEST-QUALITY-REVIEW.md`).

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what>. → <replacement>.
```

For complex findings:

```
[<confidence>] <file>:L<line>: <tag> <what>. → <replacement>.
  Detail: <explanation of why this is unnecessary and what the shorter form achieves>
```

## Confidence Calibration (Minimal axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** stdlib function exists with the exact same signature and behavior.
- **9:** Dead code with no callers. Or: docstring directly contradicts the new code behavior.
- **8:** Clear duplication with an existing function doing the same thing in the same module.
- **6-7:** Likely unnecessary but the author might know about a planned second consumer.
- **4-5:** Could be shorter but the current form is arguably more readable.
- **2-3:** Nitpick-level compression that trades clarity for brevity.
- **1:** Pure style preference disguised as a minimality concern.

## Rules

- Only examine the diff, not the entire file (unless needed to verify a `redundant:` claim).
- Security checks are NOT redundant — defense-in-depth is intentional. Do not flag:
  - Redundant validation at trust boundaries
  - Explicit error paths for "can't happen" cases
  - Protocol conformance steps that prevent future misuse
  - Exhaustive switch/enum handling
- Aim for one-line-per-finding brevity, but expand if a shrink suggestion requires showing the replacement code.

## Boundaries

- **vs Quality:** If the fix is "delete code" → Minimal. If the fix is "rethink the approach (and the result happens to be shorter)" → Quality. Minimal findings have an obvious mechanical replacement. Quality findings require judgment about what the replacement *should be*.
- **vs Style:** Minimal is about unnecessary complexity (remove it). Style is about convention conformance (rewrite it to match the pattern). If code follows conventions but is unnecessarily verbose, it's Minimal. If code is minimal but breaks naming conventions, it's Style.
