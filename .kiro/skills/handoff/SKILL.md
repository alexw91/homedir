---
name: handoff
description: Create a durable, self-contained Markdown document for sharing with people or agents. Use when the user says "handoff", "save context", "wrap up", "write this up", "summarize for [person]", "decision doc", "briefing", "status update", or wants to turn conversation context into a shareable reference.
argument-hint: "What should this document help its readers understand or do? (e.g., 'brief the team on PQ status', 'record the SHA-1 decision', 'handoff unfinished work to the next agent')"
inclusion: manual
---

Create a durable, self-contained Markdown document from the current conversation. Determine the document's purpose, audience, and type from the user's request or argument. Default to `reference` when the type is unclear. Use `handoff` only when the user asks another agent or session to continue work.

## Audience and Diegetic Default

Write diegetically unless the user explicitly asks for a transcript, session history, or other process record. State what exists, what happened, what was decided, and what the evidence shows. Remove drafting history, authoring commentary, and references such as "this conversation," "the previous handoff," or "the analysis above."

Every document must stand on its own for its intended audience:

- Give readers the context and definitions they need without access to the originating conversation.
- Use sources the audience can open. Prefer durable URLs, repository-relative source locations for readers with repository access, tickets, code reviews, dashboards, and published documents.
- Treat files under `agent-context/handoffs/` as working material, not provenance. Never cite, link to, or require another local handoff document. Verify its claims against an accessible primary source before carrying them forward.
- If an inaccessible local artifact is the only support for a claim, omit the claim and report the missing evidence outside the document as `Blocking`.

A literal agent handoff may include work history, local state, and next-session instructions because those details belong to that genre. Keep them limited to what the receiving agent needs, and use repository-relative paths rather than machine-specific absolute paths.

## Document Types

### reference (default)

Evergreen technical reference, investigation summary, or analysis result. Self-contained and useful months later without the conversation that produced it.

### briefing

Context document for a human reader such as a colleague, manager, skip-level, or cross-team stakeholder. Written in prose, not bullet-soup. Assumes the reader has the stated domain context but no session context.

### decision

Frames a question that needs resolution. Presents options with tradeoffs and a recommendation. Written so a reviewer can approve, reject, or ask for more data without a meeting.

### status-update

Periodic progress report for a project or workstream. Covers a specific time window, reports metrics, and is structured for reuse in a shared sync document.

### handoff

Agent-to-agent continuation document. Written for a fresh agent session that has no memory of the originating conversation. Use only when work must continue in another agent or session.

## Storage Convention

Unless the user specifies another destination, save to:

```
agent-context/handoffs/YYYY/MM/YYYY-MM-DD.NN - Descriptive Title.TYPE.md
```

Where `YYYY/MM/` are subdirectories for year and zero-padded month, such as `2026/07/`. Create directories as needed.

Rules:

- `YYYY-MM-DD` is today's date.
- `NN` is a zero-padded sequence number from 01 to 99, unique within its date.
- Before choosing `NN`, list existing files in the month directory matching today's date prefix. Pick the next unused number.
- The separator between the prefix and title is ` - ` (space-dash-space).
- The title identifies the document's topic without opening the file.
- `TYPE` is `reference`, `briefing`, `decision`, `status-update`, `handoff`, or `transcript`.
- A `.handoff.md` and `.transcript.md` for the same session may share a prefix. Two files of the same type must not share a prefix.
- The storage path is not a source. Do not cite it or require readers to access neighboring documents in this directory.

## Systems Owned by Another Team

Apply this branch when the document describes, documents, or scopes changes to systems owned by another team. Establish how the affected system works today before describing the change. This gives every reader the same model and lets the owning team correct misunderstandings before those assumptions shape later work.

### Teach the current system first

Add a `How the system works today` section, or a domain-specific equivalent, before the change analysis, scope, implementation details, or next steps. Write for a technically strong reader who does not know the system.

Build the explanation from the outside in:

1. State the system's purpose in one sentence.
2. Name the actors, services, and owning teams involved in the affected path.
3. Trace the normal control or data flow.
4. Identify the exact boundary the change touches.
5. Explain only the invariants and failure boundaries needed to evaluate the change.

Teach the shortest accurate model rather than inventorying every package or component. Use the owning team's documentation or source as evidence. Distinguish verified behavior from inference, and state what the investigation did not verify.

Place the current-state section here:

| Document type | Placement |
|---|---|
| `reference` | At the start of `Content` |
| `briefing` | At the start of `Background` |
| `decision` | After `Summary` and before `The Problem` |
| `status-update` | After `Status Summary` when the system model is needed to interpret the change |
| `handoff` | After `Context` and before constraints or proposed next steps |

### Draw the model

Include at least one Mermaid diagram of the affected current-state path immediately after its shortest accurate prose description.

- Use `flowchart` for components, ownership boundaries, and data or control flow.
- Use `sequenceDiagram` when ordering, retries, asynchronous work, or request lifecycles carry the argument.
- Give each diagram one teaching goal. Keep it to roughly ten nodes or participants unless removing one would make the model inaccurate.
- Use the system's canonical terms in labels. Show ownership or responsibility where it affects the change.
- Introduce the diagram with the point it demonstrates. Follow it with the boundaries, simplifications, or omitted cases a reader must know.
- Add a second target-state or changed-state diagram only when the change alters ownership, boundaries, or ordering and the difference is not clear from prose.
- Keep package inventories, internal identifiers, and uncommon edge cases in prose, tables, or appendices.
- Render-check every Mermaid block before delivery.

This branch is complete only when the current-state model precedes the change, the owning team can identify and correct assumptions about its system, every diagram agrees with the prose and renders successfully, and every deliberate simplification is disclosed.

## Structure by Type

### reference

```markdown
# Title

## Summary
What this document covers and why it matters.

## Content
The technical substance. Optimize for both linear reading and random-access lookup. Use descriptive headings, tables, and code blocks when they improve comprehension. A reader should be able to read top-to-bottom on first encounter, then jump directly to a section later.

## Key Findings
The main conclusions. A reader who stops here should still understand the important results.

## Sources
Accessible links, repository-relative source locations, commands, or data sources that support the document.
```

### briefing

```markdown
# Title

## TL;DR
One paragraph: what happened, what it means, and what the reader needs to do.

## Background
The context the reader needs. Keep it short if the intended audience already knows the domain.

## Details
The substance, organized by topic. Include data tables and metrics when they support the argument.

## Ask
The required decision, awareness, review, or action. Name who must act, by when, and the consequence of inaction. If the document is purely informational, say so.

## Appendices (optional)
Deep reference material for readers who want to verify claims, understand the timeline, or inspect technical details. Each appendix must be independently readable.
```

### decision

```markdown
# Decision Required: [Specific Question in Title Form]

---

## Summary
Lead with the recommendation and why, the key constraint, and the quantitative impact of deciding versus waiting.

## The Problem
State what is blocked and which constraint or event requires a decision. Describe the concrete situation that makes the status quo untenable.

## Options at a Glance

| Option | Key Metric | Customer Risk | Pros | Cons | Timeline |
|--------|-----------|---------------|------|------|----------|
| 1. ... | ... | ... | ... | ... | ... |
| **2. [Recommended]** | ... | ... | ... | ... | ... |
| 3. ... | ... | ... | ... | ... | ... |

## Options
For each option, explain what it does, its quantitative impact, dependencies on other teams, timeline, reversibility, and what happens if circumstances change.

## Risk Assessment
Present evidence-backed arguments for and against the recommended option. State the tradeoff the reviewer is being asked to accept.

## Data
Provide the tables, scan results, telemetry, or computed analysis that support the claims. Cite accessible sources and make the analysis reproducible.

## Recommendation
Restate the recommended option, why, and the accepted tradeoff. Include the concrete actions required before deployment if approved.

## References
Numbered citations to accessible telemetry sources, prior decisions, RFCs, tickets, code reviews, or scripts.
```

### status-update

A periodic progress report for a project or workstream. Write `Status Summary` for an external audience so it can be copied into a shared sync document, Slack thread, or email without editing.

```markdown
# Title — Period Start to Period End, Year

## Sources
Accessible Slack threads, commit logs, dashboards, tickets, and published documents used to produce the update.

## Status Summary
Lead with the headline, then key metrics, then what changed during the period.

## Metrics

| Metric | Previous | Current | Delta |
|--------|----------|---------|-------|
| ... | ... | ... | ... |

## Progress
What happened during the period, organized by topic or date. Group related items and link accessible code reviews, tickets, and documents.

## Risks and Blockers
For each risk or blocker, state what it is, who owns the next action, and what happens if it remains unresolved.

## Next Period
Planned work for the next cycle, stated specifically enough to verify in the next update.

## Links
The key dashboards, planning documents, code reviews, and external sync documents.
```

### handoff

```markdown
# Title

## Status
The work state: done, blocked, in progress, or transferred mid-task.

## Context
The work completed, decisions made, problems solved, and relevant dead ends.

## Constraints
Locked decisions, safety boundaries, and matters the receiving agent must not change or revisit without explicit human approval.

## Current State
Modified files, branches, commands, and produced artifacts. Use repository-relative paths.

## Key Inputs
The accessible files or URLs the receiving agent must read before continuing. Do not point to another local handoff document.

## Next Steps
Numbered, imperative actions in execution order. Make them specific enough for the receiving agent to start without reconstructing the originating conversation.

## Open Questions
Unresolved decisions that require human input before work can continue.

## Deferred
Adjacent work that remains explicitly out of scope.

## Suggested Skills
Skills the receiving agent should invoke, such as `grill-me` or `write-commit-message`.
```

## Completion Contract

The document is complete only when every check passes:

1. The document type and level of technical detail match the intended audience and purpose.
2. Every sentence belongs to the document's subject or is required by its genre.
3. The document stands alone without the originating conversation, an LLM session, or an earlier draft.
4. Every reference is accessible to the intended audience.
5. No claim depends on a file under `agent-context/handoffs/`, a scratch file, or a machine-specific absolute path.
6. Every factual claim has an accessible source, is clearly marked as inference, or appears outside the document in `Blocking`.
7. Sensitive information such as credentials, secrets, and personally identifiable information is absent or redacted.
8. Every Mermaid block agrees with the prose and renders successfully.

## Rules

- Use the user's arguments to determine purpose, audience, type, and focus.
- Include enough context for the document to stand alone. Cite accessible sources instead of duplicating full plans, issues, commits, diffs, or external documents.
- Prefer concise writing, but preserve every fact the audience needs to understand the subject or take the requested action.
- Match tone to the audience. Human-facing documents use clear prose. Agent handoffs may be terse and instruction-heavy.
- Apply a final diegetic pass before delivery. Remove session residue, local-only provenance, inaccessible references, drafting commentary, and machine-specific paths unless the genre explicitly requires the information.
