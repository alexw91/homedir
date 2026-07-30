# [Axis Name] Review (Sub-skill)

<!-- 
Template for creating new review axes.
Copy this file to <axis-name>/<AXIS-NAME>-REVIEW.md and fill in each section.
Delete this comment block and all placeholder text when done.
-->

[1-2 sentence description of what this axis reviews and the mindset the reviewer should adopt.]

## Core Question

**"[The single question this axis answers about the code under review.]"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** [Which git commands this axis typically runs and what it inspects selectively.]

**Remote mode:** [How this axis works from the inline diff and platform API.]

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `stale-cache (new):`, `blocking-main-thread (new):`). The same output format, confidence scoring, and verdict rules apply.

<!--
Each item combines:
- The tag (used in output)
- The check to perform (what to look for)
- The verdict it drives when confidence ≥ 8

Format:
N. `tag:` - **Bold question?** Description of what to look for.
   When to flag vs when to pass. What the fix looks like.
   Verdict ≥ 8: FIX REQUIRED | NEEDS DISCUSSION.
-->

1. `tag-name:` - **Question to ask?** [What to look for. What constitutes a finding. What the fix looks like.] Verdict ≥ 8: `FIX REQUIRED`.

2. `tag-name:` - **Question to ask?** [What to look for.] Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `tag-name:` - **Question to ask?** [What to look for.] Verdict ≥ 8: `FIX REQUIRED`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what's wrong>. → <fix>.
```

<!--
If this axis has variant formats (e.g., commit-level findings):

For commit-message-level findings:
[<confidence 1-10>] commit <short-sha>: <tag> <what's wrong>. → <fix>.
-->

## Confidence Calibration ([Axis Name] axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** [What a 10 looks like — provably wrong, zero ambiguity.]
- **9:** [Near-certain. Strong evidence, any senior engineer would agree.]
- **8:** [Confident. Clear problem, minor assumptions.]
- **6-7:** [Probable but depends on context the reviewer can't see.]
- **4-5:** [Possible. Worth raising but not blocking.]
- **2-3:** [Unlikely. Nitpick-level.]
- **1:** [Barely worth mentioning.]

## Rules

<!--
Behavioral rules for the sub-agent:
- What to inspect and how (local vs remote mode)
- What NOT to flag (false positive avoidance)
- Boundary rules with other axes
-->

- [Rule about what to inspect.]
- [Rule about what NOT to flag.]
- Do NOT flag [things that belong to another axis].
## Boundaries

<!--
Clarify where this axis ends and other axes begin.
-->

- **vs [Other Axis]:** [What belongs here vs there. Include a distinguishing test.]
