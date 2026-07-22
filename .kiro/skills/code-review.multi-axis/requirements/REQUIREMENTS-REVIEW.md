# Requirements Review (Sub-skill)

Review the diff for fidelity to the originating requirements — issue, PRD, or task description. Does the code do what was asked?

NOTE: "Requirements" here means the feature requirements from an issue tracker, PRD, or task description. It does NOT mean protocol specifications (RFCs, NIST, FIPS). Protocol conformance belongs in the Security axis.

## Inputs

You will receive:
1. The diff content (pre-computed by the orchestrator)
2. A requirements context package containing some or all of:
   - `[HUMAN]` — the original raw user message(s) that initiated this work
   - `[EXTERNAL: <url>]` — fetched content from issue trackers, PRDs, or tickets
   - `[AGENT CONTEXT]` — summary of session decisions and clarifications
   - `[ASSUMPTIONS — verify these]` — gaps the orchestrator identified

Treat `[HUMAN]` and `[EXTERNAL]` blocks as authoritative requirements. Treat `[AGENT CONTEXT]` and `[ASSUMPTIONS]` as supplementary — useful for understanding intent but not binding requirements unless the human confirmed them.

## Process

1. Read the requirements. Identify the concrete requirements — what was asked for.
2. Read the diff. Identify what was implemented.
3. Compare. Report three categories of findings.

## Finding Categories

**MISSING** — A requirement that is not implemented (or only partially implemented) in the diff.

**SCOPE CREEP** — Behavior in the diff that the requirements did not ask for. This is not always bad (defensive error handling, necessary refactoring to enable the feature), but it should be noted.

**WRONG** — A requirement that looks implemented but where the implementation appears to contradict what was asked for.

## Format

One line per finding with confidence score:

```
[<confidence 1-10>] <category>: <requirement summary>. Cite: <requirements line or section>.
```

For complex findings:

```
[<confidence>] <category>: <requirement summary>. Cite: <requirements line or section>.
  Detail: <explanation of the gap between requirements and implementation>
```

## Rules

- Quote or paraphrase the specific requirement for each finding. Don't make vague claims.
- If the requirements are ambiguous, note the ambiguity rather than asserting a violation.
- Scope creep is informational, not blocking — flag it but don't mark it FIX REQUIRED unless it introduces risk.
- If the requirements contain "nice to have" or "stretch goal" items, don't flag them as MISSING unless the diff claims to be complete.

## Verdict

Follow `OUTPUT-CONTRACT.md` exactly.

**Confidence calibration (Requirements axis):**

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Requirement uses the word "must" or "shall" and is unambiguously absent from the diff.
- **9:** Requirement is clearly stated and the diff implements the opposite behavior.
- **8:** Requirement is explicit; diff partially implements it but misses a stated sub-requirement.
- **6-7:** Requirement is ambiguous — could be interpreted as met depending on reading.
- **4-5:** Implied requirement not explicitly stated. Reasonable people could disagree on whether it's in scope.
- **2-3:** Speculative — requirement might be satisfied by code outside the diff that wasn't provided.
- **1:** Barely related to the stated requirements. Reporting for completeness only.

MISSING or WRONG findings scoring ≥ 8 drive `verdict: FIX REQUIRED`.
Ambiguous findings scoring ≥ 8 drive `verdict: NEEDS DISCUSSION`.
SCOPE CREEP findings never drive FIX REQUIRED on their own.
