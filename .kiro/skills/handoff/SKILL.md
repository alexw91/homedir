---
name: handoff
description: Produce a structured document from the current conversation — agent handoff, human briefing, decision doc, status update, or reference material. Use when user says "handoff", "save context", "wrap up", "write this up", "summarize for [person]", "decision doc", "briefing", "status update", or wants to capture session work as a shareable document.
argument-hint: "What is this document for? (e.g., 'handoff to next session', 'briefing for manager on PQ status', 'decision: whether to remove SHA-1')"
inclusion: manual
---

Produce a structured document from the current conversation. Infer the document type from the user's request or argument. Default to `handoff` if unclear.

## Document Types

### handoff (default)
Agent-to-agent continuation document. Written for a fresh agent session that has no memory of this conversation.

### briefing
Context document for a human reader (colleague, manager, skip-level, cross-team stakeholder). Written in prose, not bullet-soup. Assumes the reader has domain context but not session context.

### decision
Frames a question that needs resolution. Presents options with tradeoffs and a recommendation. Written so a reviewer can approve, reject, or ask for more data without a meeting.

### reference
Evergreen technical reference, investigation summary, or analysis result. Self-contained — should be useful months later without needing to read the conversation that produced it.

### status-update
Periodic progress report for a project or workstream. Covers a specific time window, reports metrics, and is structured to be copy-pasted into an external sync document.

## Path Convention

Save to:

```
agent-context/handoffs/YYYY/MM/YYYY-MM-DD.NN - Descriptive Title.TYPE.md
```

Where `YYYY/MM/` are subdirectories for year and zero-padded month (e.g., `2026/07/`). Create directories as needed.

Rules:
- `YYYY-MM-DD` is today's date.
- `NN` is a zero-padded sequence number (01–99), unique within its date.
- Before choosing NN, list existing files in the month directory matching today's date prefix. Pick the next unused number.
- The separator between prefix and title is ` - ` (space-dash-space).
- The title should identify the document's topic without opening the file.
- `TYPE` is the document type: `handoff`, `briefing`, `decision`, `reference`, `status-update`, or `transcript`.
- A `.handoff.md` and `.transcript.md` for the same session MAY share a prefix. Two files of the same type MUST NOT share a prefix.

## Structure by Type

### handoff

```markdown
# Title

## Status
What state the work is in: done, blocked, in-progress, or handed-off-mid-task.

## Context
What the session accomplished. Key decisions made, problems solved, dead ends hit.

## Constraints
Decisions already locked. Safety boundaries. Things the next session MUST NOT change
or re-decide without explicit human approval.

## Current State
Files modified, branches created, commands run, artifacts produced. Reference by path.

## Key Files
Paths or URLs the next session should read before starting work.

## Next Steps
Numbered, imperative actions. What to do first, second, third. Be specific enough
that the next agent can execute without asking clarifying questions.

## Open Questions
Unresolved decisions requiring human input before the next session can proceed.

## Deferred
Work that is adjacent but explicitly out of scope for this handoff. Prevents the
next session from treating nearby tasks as implied scope.

## Suggested Skills
Skills the next agent should invoke (e.g., `brazil`, `review.aweibel`, `create-s2n-sec-patch`).
```

### briefing

```markdown
# Title

## TL;DR
One paragraph: what happened, what it means, what you need from the reader.

## Background
Context the reader needs. Keep short if they already know the domain.

## Details
The substance. Organize by topic. Include data tables and metrics where they
support the argument.

## Ask
What you need: a decision, awareness, review, action. Be specific about who,
by when, and consequences of inaction. If purely informational, say so.

## Appendices (optional)
Deep reference material for readers who want to verify claims, understand timeline,
or see raw technical details. Each appendix should be independently readable.
```

### decision

```markdown
# Decision Required: [Specific Question in Title Form]

---

## Summary
2-3 paragraphs. Lead with the headline (what to do and why), the key constraint,
and the quantitative impact of deciding vs. not deciding.

## The Problem
What specifically is blocked. What constraint or event triggered this decision.
Not generic background — the concrete situation that makes the status quo untenable.

## Options at a Glance

| Option | Key Metric | Customer Risk | Pros | Cons | Timeline |
|--------|-----------|---------------|------|------|----------|
| 1. ... | ... | ... | ... | ... | ... |
| **2. [Recommended]** | ... | ... | ... | ... | ... |
| 3. ... | ... | ... | ... | ... | ... |

## Options (detailed)
Per-option subsections (H3) with full analysis. Each option: what it does,
quantitative impact, dependencies on other teams, timeline, reversibility,
and what happens if circumstances change after choosing it.

## Risk Assessment
For the recommended option specifically. Structure as "Arguments for" and
"Arguments against" with data backing each point. Acknowledge the tradeoff
being asked of the reviewer.

## Data
Tables, scan results, telemetry, or computed analysis backing the claims above.
Cite sources. Make the analysis reproducible (link to scripts or queries).

## Recommendation
Restate which option, why, and the tradeoff being accepted. Include
"Required actions before deployment" — concrete operational steps that must
happen if approved.

## References
Numbered citations to telemetry sources, prior decisions, RFCs, tickets, or scripts.
```

### reference

```markdown
# Title

## Summary
What this document covers, when produced, and why it matters.

## Content
The technical substance. Optimize for both linear reading AND random-access lookup.
Use thick headings, tables, and code blocks liberally. A reader should be able to
read top-to-bottom on first encounter, then jump directly to a section later.

## Key Findings
Main conclusions, distilled. If the reader only reads this section, they should
walk away with the important takeaways.

## Sources
Links, artifacts, commands, or data sources used to produce this document.
```

### status-update

Periodic progress report for a project or workstream. The "Status Summary" section should be written for an external audience and be directly copy-pasteable into a shared sync document, Slack thread, or email.

```markdown
# Title — Period Start to Period End, Year

## Sources
What was reviewed to produce this update: Slack channels, commit logs, dashboards, prior status updates. Include links.

## Status Summary
2-3 paragraphs for the external audience. Leads with the headline, then key metrics, then what changed. Written to be copy-pasted into the team's shared status document without editing.

## Metrics

| Metric | Previous | Current | Delta |
|--------|----------|---------|-------|
| ... | ... | ... | ... |

## Progress
What happened during the period. Organize by topic or by date — choose whichever makes the content clearest. Group related items. Link CRs, tickets, and docs.

## Risks and Blockers
What is stuck, what might slip, what depends on external teams. For each: what it is, who owns unblocking it, what happens if unresolved.

## Next Period
Planned work for the next cycle. Specific enough to be falsifiable at the next update.

## Links
Key URLs: dashboards, planning docs, CRs, external sync documents.
```

## Rules

- Do not duplicate content already captured in other artifacts (plans, issues, commits, diffs). Reference them by path or URL.
- Redact sensitive information (API keys, passwords, PII).
- If the user passed arguments, use them to determine type, audience, and focus.
- Prefer concise writing, but completeness over brevity. Ensure all meaningfully useful context from the parent session reaches the reader. Missing context leads to misunderstandings, invalid results, rework, and churn.
- Match tone to audience: agent handoffs can be terse and reference-heavy; human briefings should read as clear prose.
