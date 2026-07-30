---
name: code-review.multi-axis
description: Multi-axis code review to find issues across coding style, requirements adherence, security review, code minimality, and software engineering quality dimensions. Use when user says "review since", "code-review.multi-axis", "code review", "pre-CR check", or wants feedback on changes before submitting.
---

# Multi-Axis Code Review

Review the diff between the current working state and a fixed point across independent axes. Each axis runs as a parallel sub-agent. Results are aggregated into a flat findings index with a unified verdict.

## Invocation

```
code-review.multi-axis [<axes>] [since <fixed-point>]
```

- `code-review.multi-axis` — default: reviews all unpushed work (local commits + uncommitted changes) against `@{upstream}`
- `code-review.multi-axis since main` — explicit fixed point
- `code-review.multi-axis all since HEAD~3` — force every axis with explicit range
- `code-review.multi-axis security since main` — run only the Security axis
- `code-review.multi-axis security minimal since v2.1.0` — run only the named axes

Valid axis names: `style`, `requirements`, `security`, `minimal`, `quality`, `architecture`, `performance`, `test-quality`, `backwards-compatible`, `ready-for-human-review`, `all`.

When `all` is specified or no axes are named, run every axis. There is no skip logic in the orchestrator — every enabled axis always runs. Sub-agents handle "nothing to say" by returning `findings: 0 / verdict: SHIP`.

## Modes

This skill operates in two modes depending on the input:

**Local mode** — reviewing your own unpushed work in a local git repo. The orchestrator passes sub-agents a git command to run; sub-agents fetch the diff themselves and have full filesystem access for surrounding context. This is the default when no URL is provided.

**Remote mode** — reviewing an existing CR/PR on code.amazon.com or GitHub. The orchestrator fetches the diff once via platform API and passes it inline to sub-agents. Sub-agents cannot run git commands (no local clone exists) but receive a recipe for fetching additional files via the platform API if needed.

The key difference: in local mode, sub-agents are self-sufficient and the orchestrator stays lean. In remote mode, the orchestrator does more upfront work (one API fetch) to avoid N sub-agents each throttling the same remote API.

## Orchestrator Rules

The orchestrator is a dispatcher and aggregator. It MUST NOT:
- Read sub-skill files (the `<axis>/<NAME>-REVIEW.md` files). These are exclusively for the sub-agents.
- Analyze the diff content for review purposes (local mode). In remote mode, the orchestrator fetches the diff once to avoid N sub-agents throttling the API, but does not analyze it.
- Produce findings of its own. All findings come from sub-agents.

The orchestrator MUST:
- Determine the mode (local vs remote) and gather metadata (step 1-2).
- Spawn sub-agents, passing each one its skill file path via `contextFiles` and the appropriate input per `INPUT-CONTRACT.md`.
- Collect sub-agent responses and format the final report (step 5).

This keeps the orchestrator's context lean and allows the skill to scale to many axes without exhausting the parent session.

## Process

### 1. Detect mode

- Input is a `CR-XXXXXXXX` ID or `code.amazon.com/reviews/...` URL → **remote (CRUX)**
- Input is a GitHub PR URL (`github.com/<owner>/<repo>/pull/<N>`) → **remote (GitHub)**
- Input is a git ref, `since <ref>`, or no input (default) → **local**

### 2. Determine the fixed point and gather metadata

**Local:**
- If `since <ref>` is provided, use that ref directly.
- If no `since` is provided, use `@{upstream}`. Run `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}` to verify it exists. If it does NOT exist, STOP with this error:
  > **Error:** No upstream configured for the current branch. Either set one with `git branch --set-upstream-to=origin/<branch>` or specify a fixed point explicitly: `code-review.multi-axis since <ref>`
  
  Do not guess. Do not fall back.
- Gather lightweight metadata (do NOT capture the full diff):
  ```bash
  git -P log @{upstream}..HEAD --format="%H %s"   # commit list
  git -P diff HEAD --stat                          # check for uncommitted changes
  git -P log @{upstream}..HEAD --oneline | wc -l   # commit count for header
  git -P diff @{upstream} --stat | tail -1         # file count for header
  ```
- If uncommitted changes exist, append `(uncommitted) Working tree changes not yet committed` to the commit list.
- Determine the diff command sub-agents will run: `git -P diff @{upstream}` (or `git -P diff <ref>`).

**Remote (CRUX):**
- Fetch the CR using `mcp_builder_mcp_readinternalwebsites` with the CR URL (include `?diffConfig=all`).
- Extract: diff content, file list, CR title, CR description, linked issues.

**Remote (GitHub):**
- Fetch the diff using `mcp_github_pull_request_read` with method `get_diff`.
- Fetch metadata using `mcp_github_pull_request_read` with method `get` for title, description, linked issues.

### 3. Check requirements context

If the orchestrator has NO requirements context in its session memory (no links to tickets, no PRD references, no prior conversation about what this feature is supposed to accomplish), pause and ask the user:

> I don't have requirements context for this change. The Requirements axis needs something to compare the code against. Choose one:
>
> 1. **Skip** — run the Requirements axis without session context (it may still find issue links in commit messages)
> 2. **Provide links** — give me a ticket URL, PRD path, or spec file to pass to the Requirements reviewer
> 3. **Grill** — start a brief grilling session where I ask you questions about the intended behavior, then use your answers as the requirements baseline

If **Skip**, proceed with no requirements session context.
If **Provide links**, wait for the links, then include them as session context.
If **Grill**, run 3-5 focused questions about intent/scope/acceptance criteria and use the answers as `[AGENT CONTEXT]`.

If the orchestrator already has requirements context from the session, skip this prompt.

### 4. Spawn all sub-agents in parallel

Use `invoke_sub_agent` with `general-task-execution` for each axis. Provide each sub-agent:

**Both modes:**
- The sub-skill file via `contextFiles` (path only — do NOT read it yourself)
- `OUTPUT-CONTRACT.md` via `contextFiles`
- `INPUT-CONTRACT.md` via `contextFiles`
- Session context from step 3 (ephemeral information from the orchestrator's memory — only what isn't on disk)

**Local mode additionally:**
- The diff command to run (e.g., `git -P diff @{upstream}`)
- The commit list (hashes + subjects, plus `(uncommitted)` if applicable)

**Remote mode additionally:**
- The diff content inline (fetched in step 2)
- Platform context: which platform (CRUX or GitHub), repo/package name, base branch
- A "read file" recipe for fetching surrounding context:
  - CRUX: `mcp_builder_mcp_readinternalwebsites` with `code.amazon.com/packages/<REPO>/blobs/<BRANCH>/--/<PATH>`
  - GitHub: `mcp_github_get_file_contents` with `owner`, `repo`, `path`, `ref`
- CR/PR metadata: title, description, linked issues

Sub-agent skill files by axis:
- `style/STYLE-REVIEW.md`
- `requirements/REQUIREMENTS-REVIEW.md`
- `security/SECURITY-CODE-REVIEW.md`
- `minimal/MINIMAL-REVIEW.md`
- `quality/QUALITY-REVIEW.md`
- `architecture/ARCHITECTURE-REVIEW.md`
- `performance/PERFORMANCE-REVIEW.md`
- `test-quality/TEST-QUALITY-REVIEW.md`
- `backwards-compatible/BACKWARDS-COMPATIBLE-REVIEW.md`
- `ready-for-human-review/READY-FOR-HUMAN-REVIEW.md`

All sub-agents MUST return output conforming to `OUTPUT-CONTRACT.md`.

### 5. Aggregate and present

**Report header:**
- Local: `## Review: <fixed-point>..HEAD (<N> commits, <M> files)`
- Remote: `## Review: CR-12345678 (<N> files)` or `## Review: github.com/aws/s2n-tls/pull/4567 (<N> files)`

**Output format:**

```markdown
## Review: <identifier> (<stats>)

### Findings

1. [SECURITY 9/10] FAIL: <checklist item>. <one-line summary>. → <suggested fix>.
2. [MINIMAL 8/10] <tag>: <file>:L<line>. <what>. <replacement>.
3. [STYLE 9/10] <file>:L<line>. <violation>. Cite: <convention source>.
4. [READY-FOR-HUMAN-REVIEW 9/10] <file>:L<line>. <tag>: <what>. → <fix>.

### Warnings (confidence < 8)

5. [SECURITY 5/10] <checklist item>. <speculative concern>. → <suggestion>.
6. [MINIMAL 6/10] <tag>: <file>:L<line>. <what>. <replacement>.

### Verdict: <SHIP|FIX REQUIRED|NEEDS DISCUSSION> (<count per axis>)

style-review: Passed. 0 findings.
requirements-review: Passed. 0 findings.

Top priorities: #1, #3.
```

**Confidence scoring:**
- Findings scoring **8-10** → **Findings** section (blocking or near-blocking).
- Findings scoring **1-7** → **Warnings** section (non-blocking, informational).
- The verdict is determined ONLY by findings in the Findings section. Warnings never block.

**Verdict aggregation:**
- Any axis says FIX REQUIRED → overall FIX REQUIRED
- Any axis says NEEDS DISCUSSION (and none say FIX REQUIRED) → overall NEEDS DISCUSSION
- All axes pass → SHIP

**Axes with no findings:** render as `<axis>-review: Passed. 0 findings.`

Do NOT merge or rerank findings across axes. Do NOT deduplicate — they represent different lenses on the same code. Multiple axes flagging the same line is a stronger signal, not redundancy.

**Numbering rule:** All numbered items in the report share a single continuous sequence starting at 1. The Findings section, Warnings section, and any summary or priority list after the verdict MUST continue the same numbering — never restart at 1. This ensures the user can say "fix #3" unambiguously. If a post-verdict summary references findings, use the same numbers assigned in the Findings/Warnings sections above (e.g., "Top priorities: #1, #4, #2").

After the findings index and verdict, include the full per-axis reports verbatim from the sub-agents under collapsible sections.

## Orchestrator Do-Not Rules

These rules prevent the orchestrator from consuming context that should be reserved for sub-agents:

- Do NOT read sub-skill files (`<axis>/<NAME>-REVIEW.md`). Pass paths via `contextFiles`.
- Do NOT read local files to pass their content to sub-agents. They have filesystem access.
- Do NOT search for convention docs, linter configs, or requirements files. Sub-agents discover these.
- Do NOT parse commit messages for issue links. Sub-agents read commit messages themselves.
- Do NOT fetch external URLs referenced in commit messages. Sub-agents can find and fetch those.
- Do NOT analyze the diff for review purposes. The orchestrator dispatches, it does not review.

## Extensibility

To add a new review axis:
1. Create a new `<name>/` subdirectory with a `<NAME>-REVIEW.md` file in this skill directory
2. Add the axis name to the valid axis list above
3. Add any context discovery logic in step 3 (if the axis needs special context beyond the diff)
4. Add the skill file path to the list in step 4

No changes to the aggregation logic are needed — it handles any number of axes generically.
