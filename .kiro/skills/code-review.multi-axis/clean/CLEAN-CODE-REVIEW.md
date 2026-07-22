# Clean Code Review (Sub-skill)

Review the diff for unnecessary complexity. The change's best outcome is getting shorter.

## Format

One line per finding with confidence score:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what>. <replacement>.
```

For complex findings:

```
[<confidence>] <file>:L<line>: <tag> <what>. <replacement>.
  Detail: <explanation of why this is unnecessary and what the shorter form achieves>
```

## Tags

- `delete:` Dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` Hand-rolled thing the standard library or framework ships. Name the function.
- `yagni:` Abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` Same logic, fewer lines. Show the shorter form.
- `redundant:` Validation already performed by a caller or callee, OR a capability the codebase already provides (retry logic, parsing, formatting, etc.) being reimplemented locally. Remove the duplicate and use the existing mechanism.
- `new-file:` New file created when an existing file covers the same component. Example: creating a new test file when the repo's naming convention maps to an existing test file (e.g., changes to `src/foo.c` should go in `tests/foo_test.c`). Also applies to non-test files: creating `utils2.ts` when `utils.ts` already handles the same domain. Only flag if the convention-matching file exists.
- `mixed-scope:` Diff bundles unrelated changes — a bug fix mixed with a refactor, or a feature change mixed with formatting cleanup. Each logical change should be a separate commit or PR so reviewers can evaluate correctness independently. Does not apply to changes that are naturally cohesive (a feature plus its tests, a refactor that must touch multiple files atomically).
- `no-gate:` Test assertion that would pass without the change (does not gate on the new behavior). Also applies when the test asserts the implementation's output without independent evidence that the output is correct — encoding the implementation rather than the specification. If the function has a bug and the test encodes that buggy output, both pass but nothing is verified. Replacement: derive the expected value from the requirement, not from running the code.
- `stale-doc:` Comment, docstring, or header documentation that describes the old (now-changed) behavior. Replacement: update to reflect the new semantics.

## Rules

- Only examine the diff, not the entire file (unless needed to verify a `redundant:` claim).
- Security checks are NOT redundant — defense-in-depth is intentional. Do not flag:
  - Redundant validation at trust boundaries
  - Explicit error paths for "can't happen" cases
  - Exhaustive switch/enum handling
- Aim for one-line-per-finding brevity, but expand if a shrink suggestion requires showing the replacement code or if the reasoning for a `no-gate:` tag is non-obvious.

## Verdict

Follow `OUTPUT-CONTRACT.md` exactly.

**Confidence calibration (Clean axis):**

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** stdlib function exists with the exact same signature and behavior. Or: test provably passes without the change (verified by reading the assertion).
- **9:** Dead code with no callers. Or: docstring directly contradicts the new code behavior.
- **8:** Clear duplication with an existing function doing the same thing in the same module.
- **6-7:** Likely unnecessary but the author might know about a planned second consumer.
- **4-5:** Could be shorter but the current form is arguably more readable.
- **2-3:** Nitpick-level compression that trades clarity for brevity.
- **1:** Pure style preference disguised as a clean-code concern.

A `no-gate:` finding scoring ≥ 8 drives `verdict: FIX REQUIRED`.
A `stale-doc:` finding scoring ≥ 8 drives `verdict: FIX REQUIRED`.
A `mixed-scope:` finding scoring ≥ 8 drives `verdict: NEEDS DISCUSSION` (the individual changes may be fine but bundling makes review unreliable).
All other tags scoring ≥ 8 drive `verdict: NEEDS DISCUSSION`.
