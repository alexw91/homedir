# Test Quality Review (Sub-skill)

Review the diff as someone who has been woken up at 2am by a test that passed in CI but missed a real bug in production. Tests exist to prove the code works — not to prove the author wrote tests. Every test must earn its place by covering a distinct behavior that no other test covers.

## Core Question

**"Does the new source code in this diff have good test coverage, and are the new tests simple, minimal, additive, and actually testing the new code being added?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Run the diff command to get the changes. Identify production code files and test code files. For production code without corresponding tests in the diff, use filesystem access to check whether tests exist in the expected location (following the project's naming conventions). Read existing test files when needed to assess duplication or staleness.

**Remote mode:** The diff is provided inline. Identify production code vs test code from file paths. Use the platform-specific file-read recipe to check for existing test files when assessing `missing-test:` or `duplicate-test:` findings.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `flaky-setup (new):`, `test-pollution (new):`). The same output format, confidence scoring, and verdict rules apply.

1. `missing-test:` - **Is there a test for this new code?** Production code was added or modified in this diff but no corresponding test code appears. Every new function, branch, or behavior change should have a test that exercises it. Assume this diff targets a production-ready CR — if tests are planned for a follow-up, they should be in this diff instead. In local mode, check whether existing test files already cover the new code before flagging. Verdict ≥ 8: `FIX REQUIRED`.

2. `missing-error-test:` - **Is there a test that violates this precondition?** A new validation check, precondition guard, error return, or early-exit path was added but no test exercises the failure case. Every precondition should have a test that deliberately violates it and asserts the expected error behavior. Verdict ≥ 8: `FIX REQUIRED`.

3. `no-gate:` - **Does this test actually gate on the new behavior?** Test assertion that would pass even without the code change in this diff. The test does not prove the new behavior works — it would pass on the previous revision. Also applies when the test asserts the implementation's output without independent evidence that the output is correct (encoding the implementation rather than the specification). Derive expected values from the requirement, not from running the code. Verdict ≥ 8: `FIX REQUIRED`.

4. `tautological:` - **Is this test proving anything?** The test's expected value is derived from the same logic it's testing — running the production code and asserting it equals itself, or constructing the expected output using the same algorithm the source uses. If the source has a bug, the test encodes that same bug and both pass. The fix: derive expected values from an independent source (the spec, a manual calculation, a known-good reference value). Verdict ≥ 8: `FIX REQUIRED`.

5. `stale-mock:` - **Does this mock match reality?** A mock, stub, or fake in the test returns values or exhibits behavior that the real implementation no longer supports. The production code changed (new error conditions, different return shape, removed method) but the mock still reflects the old contract. The test passes against the mock but would fail against the real thing. Verdict ≥ 8: `FIX REQUIRED`.

6. `duplicate-test:` - **Does this test add coverage?** A new test exercises the same code path as an existing test with different input values but no additional branch coverage. Removing this test would not reduce the set of covered behaviors. Tests should be additive — each one covers a distinct path. Merge redundant cases into a parameterized test or remove the duplicate. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `brittle:` - **Would a safe refactoring break this test?** The test is coupled to implementation internals: private method names, internal data structures, execution order, specific log messages, or intermediate state. A refactoring that preserves all observable behavior would break this test. Tests should assert on the public contract (inputs → outputs, inputs → side effects) not on how the code achieves its result. Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `mock-verification:` - **Is this asserting behavior or implementation?** The test uses verify/calledWith/times assertions to confirm the code called specific internal methods in a specific order, rather than asserting on observable output or state. This couples the test to the call graph — any internal restructuring breaks it even when behavior is preserved. Prefer asserting on the result the caller observes. Verdict ≥ 8: `NEEDS DISCUSSION`.

9. `stale-test:` - **Does this existing test reflect the new behavior?** Production code behavior changed in this diff but an existing test still asserts the old behavior. The test passes only because it hasn't been updated to match the new semantics — it's now testing something that no longer exists. Update the test to assert the new expected behavior. Verdict ≥ 8: `FIX REQUIRED`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what's wrong>. → <fix>.
```

For missing-test findings (no specific test file line to reference):

```
[<confidence 1-10>] <production-file>:L<line>: missing-test <what needs a test>. → Add test for <behavior>.
```

For complex findings:

```
[<confidence>] <file>:L<line>: <tag> <what's wrong>. → <fix>.
  Detail: <explanation of why this test is inadequate and what a proper test looks like>
```

## Confidence Calibration (Test Quality axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Test provably passes without the code change (verified by reading the assertion against the prior state). Or: mock returns a value the real implementation can no longer produce (provable from the diff).
- **9:** New public function with branching logic and zero test assertions anywhere in the diff or existing test files. Or: test expected value is computed using the same expression as the source.
- **8:** New error path (explicit guard/throw/return-error) with no test that triggers it. Or: existing test asserts old behavior that the diff explicitly changes.
- **6-7:** Production code modified in a way that likely changes observable behavior, but existing tests might cover it indirectly (can't fully verify without running the suite).
- **4-5:** Mock verification pattern that could reasonably be argued as documenting an important interaction contract. Or: test duplication where the second test arguably improves readability.
- **2-3:** Borderline brittle coupling where the internal being tested is unlikely to change.
- **1:** Pure style preference about test structure.

## Rules

- In local mode, always check for existing test files before flagging `missing-test:`. Use the project's naming convention (e.g., `src/foo.ts` → `src/__tests__/foo.test.ts`, or `src/foo.c` → `tst/foo_test.c`). Only flag if no test file exists OR the existing test file has no assertions covering the new code path.
- In remote mode, use the platform file-read recipe to check for existing tests when confidence would otherwise be below 9. If you cannot verify, flag at confidence 8 with a note that existing coverage wasn't verified.
- Read both the production code and the test code in the diff holistically. Understand what the production code does, then assess whether the tests actually prove it works.
- For `no-gate:` and `tautological:`: mentally remove the production code change and ask "would this test still pass?" If yes, it's not gating.
- Do NOT flag test infrastructure (helpers, fixtures, factories) as needing their own tests. Test infrastructure is tested by the tests that use it.
- Do NOT flag integration tests or end-to-end tests for brittleness based solely on their scope. Brittleness applies when tests depend on implementation details, not when they depend on system behavior.

## Boundaries

- **vs Minimal:** Minimal no longer owns test quality. If a finding is about whether a test proves what it claims, it belongs here. If a finding is about unnecessary code that happens to be in a test file (dead helper function, unused import), it belongs to Minimal.
- **vs Quality:** Quality's `untestable:` tag identifies production code that's hard to test due to its structure. This axis identifies tests that fail to test effectively. If production code needs restructuring to become testable → Quality. If the production code is testable but the tests are inadequate → Test Quality.
- **vs Security:** If a missing test is specifically about a security-critical path (auth bypass, input validation for injection), Security may also flag it. Both axes flagging the same gap is a stronger signal.
