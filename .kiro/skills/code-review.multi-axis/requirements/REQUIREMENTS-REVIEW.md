# Requirements Review (Sub-skill)

Review the diff for fidelity to the originating requirements — issue, PRD, or task description. Does the code do what was asked?

NOTE: "Requirements" here means the feature requirements from an issue tracker, PRD, or task description. It does NOT mean protocol specifications (RFCs, NIST, FIPS). Protocol conformance belongs in the Security axis.

## Core Question

**"Does the implementation match what was asked for — nothing missing, nothing contradicted, nothing unasked-for that introduces risk?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

You will also receive a requirements context package containing some or all of:
- `[HUMAN]` — the original raw user message(s) that initiated this work
- `[EXTERNAL: <url>]` — fetched content from issue trackers, PRDs, or tickets
- `[AGENT CONTEXT]` — summary of session decisions and clarifications
- `[ASSUMPTIONS — verify these]` — gaps the orchestrator identified

Treat `[HUMAN]` and `[EXTERNAL]` blocks as authoritative requirements. Treat `[AGENT CONTEXT]` and `[ASSUMPTIONS]` as supplementary — useful for understanding intent but not binding requirements unless the human confirmed them.

**Local mode:** Read the requirements context, then inspect the diff using `git -P show <sha>` or `git -P diff HEAD`.

**Remote mode:** The diff and requirements context are provided inline in your prompt.

## Findings Catalog

1. `MISSING:` - **Is a stated requirement absent from the implementation?** A requirement that is not implemented (or only partially implemented) in the diff. Quote or paraphrase the specific requirement. If the requirements contain "nice to have" or "stretch goal" items, don't flag them unless the diff claims to be complete. Verdict ≥ 8: `FIX REQUIRED`.

2. `WRONG:` - **Does the implementation contradict what was asked?** A requirement that looks implemented but where the implementation appears to contradict what was asked for. The code does the opposite of, or something materially different from, what the requirement states. Verdict ≥ 8: `FIX REQUIRED`.

3. `AMBIGUOUS:` - **Is the requirement unclear enough that correctness can't be determined?** The requirements are ambiguous and the implementation chose one interpretation, but a reasonable person could read the requirement differently. Note the ambiguity rather than asserting a violation. Verdict ≥ 8: `NEEDS DISCUSSION`.

4. `SCOPE CREEP:` - **Is there behavior the requirements didn't ask for?** Behavior in the diff that the requirements did not ask for. This is not always bad (defensive error handling, necessary refactoring to enable the feature), but it should be noted so the reviewer can assess whether the extra work is appropriate or introduces risk. Never drives `FIX REQUIRED` on its own. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <category>: <requirement summary>. Cite: <requirements line or section>.
```

For complex findings:

```
[<confidence>] <category>: <requirement summary>. Cite: <requirements line or section>.
  Detail: <explanation of the gap between requirements and implementation>
```

## Confidence Calibration (Requirements axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Requirement uses the word "must" or "shall" and is unambiguously absent from the diff.
- **9:** Requirement is clearly stated and the diff implements the opposite behavior.
- **8:** Requirement is explicit; diff partially implements it but misses a stated sub-requirement.
- **6-7:** Requirement is ambiguous — could be interpreted as met depending on reading.
- **4-5:** Implied requirement not explicitly stated. Reasonable people could disagree on whether it's in scope.
- **2-3:** Speculative — requirement might be satisfied by code outside the diff that wasn't provided.
- **1:** Barely related to the stated requirements. Reporting for completeness only.

## Rules

- Quote or paraphrase the specific requirement for each finding. Don't make vague claims.
- If the requirements are ambiguous, note the ambiguity rather than asserting a violation.
- Scope creep is informational, not blocking — flag it but don't mark it FIX REQUIRED unless it introduces risk.
- If the requirements contain "nice to have" or "stretch goal" items, don't flag them as MISSING unless the diff claims to be complete.
- The Findings Catalog is not exhaustive. If you identify a requirements concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `scope-creep (new):`, `undocumented-assumption (new):`). The same output format, confidence scoring, and verdict rules apply.

## Boundaries

- **vs Security:** Protocol specifications (RFCs, NIST, FIPS) belong in the Security axis, not here. This axis covers feature requirements from issue trackers, PRDs, or task descriptions.
- **vs Quality:** If the code implements the requirement but in a poor way, that's Quality. If the code doesn't implement the requirement at all, that's Requirements.
