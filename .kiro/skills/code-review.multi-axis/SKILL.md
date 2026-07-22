---
name: code-review.multi-axis
description: Multi-axis code review to find issues across coding style, requirements adherence, security review, code cleanliness, and software engineering quality dimensions. Use when user says "review since", "code-review.multi-axis", "code review", "pre-push check", or wants feedback on changes before submitting.
---

# Multi-Axis Code Review

Review the diff between `HEAD` and a fixed point across up to five independent axes: Style, Requirements, Security, Clean, and Quality. Each axis runs as a parallel sub-agent. Results are aggregated into a flat findings index with a unified verdict.

## Invocation

```
code-review.multi-axis [<axes>] since <fixed-point>
```

- `code-review.multi-axis since main` — default: runs Style + Clean always, Requirements if a requirements source is found, Security at orchestrator discretion
- `code-review.multi-axis all since HEAD~3` — force every axis regardless of skip logic
- `code-review.multi-axis security since main` — run only the Security axis
- `code-review.multi-axis security clean since v2.1.0` — run only the named axes

Valid axis names: `style`, `requirements`, `security`, `clean`, `quality`, `solid`, `all`.

When no axes are specified, the orchestrator decides:
- **Style:** Always runs.
- **Clean:** Always runs.
- **Quality:** Always runs.
- **Requirements:** Runs if a requirements source is found. If none found, emits `requirements-review: SKIPPED (no requirements found)`.
- **Security:** Runs if the diff touches logic, control flow, auth, crypto, network, or input handling. If the diff is purely cosmetic (comments, formatting, docs-only, renames), emit `security-review: SKIPPED (trivial diff)`. When in doubt, run it.
- **SOLID:** Runs if the diff introduces or modifies class/struct/trait/interface definitions, module exports, or inheritance/composition relationships. If the diff is purely internal to existing function bodies with no boundary changes, emit `solid-review: SKIPPED (no structural changes)`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. Don't be opinionated; pass it through. If they didn't specify one, ask: "Review against what — a branch, a commit, or `main`?" Don't proceed until you have it.

### 2. Capture the diff

```bash
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

Note the commit count and files changed for the report header. Store the diff output — you will pass it to each sub-agent rather than having them re-run the command.

### 3. Discover context sources

**Style axis:**
- `.kiro/steering/*.md`
- `CONTRIBUTING.md`, `CONTEXT.md`, `STYLE.md`, `STANDARDS.md`
- `docs/adr/` (architectural decisions are conventions)
- `.editorconfig`, `eslint.config.*`, `biome.json`, `prettier.config.*`, `tsconfig.json` (note machine-enforced rules — don't re-check what tooling checks)
- If no explicit conventions docs exist, instruct the sub-agent to review the codebase and ensure new code follows existing patterns and professional best practices.

**Requirements axis (in priority order):**
1. Issue references in commit messages (`#123`, `Closes #45`, tracker links, etc.)
2. A path the user passed as an argument
3. A PRD/requirements file under `docs/`, `specs/`, `.kiro/specs/`, or `.scratch/` matching the branch name or feature
4. If nothing found: skip the Requirements axis

**Requirements axis — session context forwarding:**

When spawning the Requirements sub-agent, the orchestrator MUST assemble a context package that includes:
- **The original human ask** — the raw, unedited user message(s) that initiated this work, clearly labeled as `[HUMAN]`
- **Links to external trackers** — any issue URLs, GitHub issue URLs, or other issue tracker links found in commits or provided by the user
- **Fetched issue/PRD content** — if links were found, fetch their content and include it, labeled as `[EXTERNAL: <url>]`
- **Agent-generated summary** — if the orchestrator has additional context from the session (prior conversation, decisions made, clarifications given), include a brief summary labeled as `[AGENT CONTEXT]` explaining what was discussed and decided
- **Gaps and assumptions** — if requirements are incomplete or the orchestrator had to infer intent, note these explicitly as `[ASSUMPTIONS — verify these]`

The sub-agent must be able to distinguish human-authored requirements from agent-inferred context. When in doubt about whether something is a requirement or an interpretation, label it as an assumption.

**Security axis:**
- The diff itself
- Any `background-context.md` if present in the repo root

**SOLID axis:**
- The diff itself
- Type definitions and interface files adjacent to the changed code (to assess whether contracts are honored)

**Clean axis:**
- The diff itself

### 4. Spawn applicable sub-agents in parallel

Use `invoke_sub_agent` with `general-task-execution` for each axis. Provide each sub-agent:
- The diff content (captured in step 2 — do not have sub-agents re-run the git command)
- The relevant sub-skill file content from this skill's directory
- Any axis-specific context files discovered in step 3

Sub-agent instructions for each axis are in the corresponding subdirectory:
- `style/STYLE-REVIEW.md`
- `requirements/REQUIREMENTS-REVIEW.md`
- `security/SECURITY-CODE-REVIEW.md`
- `clean/CLEAN-CODE-REVIEW.md`
- `solid/SOLID-REVIEW.md`

All sub-agents MUST return output conforming to `OUTPUT-CONTRACT.md`. Include the contract in every sub-agent prompt so it knows the exact response format.

Sub-agents aim for one-line-per-finding brevity but MAY write multi-line or multi-paragraph descriptions for genuinely complex findings (using the `Detail:` continuation format from the contract). The orchestrator distills each finding to a single summary line for the human-facing output.

### 5. Aggregate and present

**Output format:**

```markdown
## Review: <fixed-point>..HEAD (<N> commits, <M> files)

### Findings

1. [SECURITY 9/10] FAIL: <checklist item>. <one-line summary>. → <suggested fix>.
2. [CLEAN 8/10] <tag>: <file>:L<line>. <what>. <replacement>.
3. [STYLE 9/10] <file>:L<line>. <violation>. Cite: <convention source>.
4. [REQUIREMENTS 8/10] <requirement>. <status: missing|partial|wrong>. Cite: <requirements line>.

### Warnings (confidence < 8)

5. [SECURITY 5/10] <checklist item>. <speculative concern>. → <suggestion>.
6. [CLEAN 6/10] <tag>: <file>:L<line>. <what>. <replacement>.

### Verdict: <SHIP|FIX REQUIRED|NEEDS DISCUSSION> (<count per axis>)

security-review: SKIPPED (trivial diff)
requirements-review: SKIPPED (no requirements found)
```

**Confidence scoring:**
- Sub-agents assign each finding a confidence score per `OUTPUT-CONTRACT.md`.
- Findings scoring **8-10** go in the **Findings** section — these are blocking or near-blocking.
- Findings scoring **1-7** go in the **Warnings** section — these are non-blocking, informational, for human review.
- The verdict is determined ONLY by findings in the **Findings** section. Warnings never block.

**Verdict aggregation:**
- Any axis says FIX REQUIRED (from findings ≥ 8) → overall FIX REQUIRED
- Any axis says NEEDS DISCUSSION (and none say FIX REQUIRED) → overall NEEDS DISCUSSION
- All axes pass → SHIP

**For axes that produce no findings:**

Sub-agents return exactly `findings: 0\nverdict: SHIP` per the output contract. The orchestrator renders this as:
- Security: `security-review: Passed. 0 findings.`
- Style: `style-review: Passed. 0 findings.`
- Clean: `clean-review: Passed. 0 findings.`
- Requirements: `requirements-review: Passed. 0 findings.`

Do NOT merge or rerank findings across axes. Do NOT deduplicate findings that appear in multiple axes — they represent different lenses on the same code.

After the findings index and verdict, include the full per-axis reports verbatim from the sub-agents under collapsible sections for anyone who wants the complete context.

## Extensibility

To add a new review axis:
1. Create a new `<name>/` subdirectory with a `<NAME>-REVIEW.md` file in this skill directory
2. Add the axis name to the valid axis list above
3. Add discovery logic in step 3
4. Add spawn logic in step 4

No changes to the aggregation logic are needed — it handles any number of axes generically.
