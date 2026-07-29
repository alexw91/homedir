# Sub-agent Input Contract

All review axis sub-agents receive a standardized input from the orchestrator. This contract defines what every sub-agent can expect to receive and how to access the code under review. The input differs by mode (local vs remote).

## Standard Input (both modes, all axes)

Every sub-agent always receives:

### 1. Axis skill file

Your axis-specific review instructions (e.g., `SECURITY-CODE-REVIEW.md`), provided via `contextFiles`. Follow these instructions for your review.

### 2. Session context (ephemeral, from orchestrator only)

The orchestrator passes ONLY information that exists in its memory and is not stored on disk:

- `[HUMAN]` — the original user message(s) that initiated this work
- `[AGENT CONTEXT]` — session decisions, clarifications, or constraints from the conversation
- User-provided URLs mentioned verbally (not found in commit messages or CR descriptions)

If none of these exist, this section is empty and that's fine.

---

## Local Mode Input

In local mode, you are reviewing unpushed changes in a local git repository. You have full filesystem and git access.

### Diff command

The orchestrator provides the exact git command to run to see the full combined diff:

```
git -P diff @{upstream}
```

(Or `git -P diff <ref>` if the user specified an explicit fixed point.)

Run this command yourself to see the complete changeset. You control when and whether to load the full diff into your context.

### Commit list

A list of commits included in the review, one per line:

```
<full-sha> <subject line>
<full-sha> <subject line>
...
(uncommitted) Working tree changes not yet committed
```

The `(uncommitted)` entry appears only if there are uncommitted changes in the working tree.

### How to access code (local mode)

| What you need | Command |
|---|---|
| Full combined diff (all changes vs upstream) | `git -P diff @{upstream}` |
| A single commit's patch | `git -P show <sha>` |
| Uncommitted changes only | `git -P diff HEAD` |
| List of files changed | `git -P diff @{upstream} --name-only` |
| A specific file at HEAD | `git -P show HEAD:<path>` |
| Surrounding context for a function | Use `read_file` or `read_code` tools |

Choose the minimum you need. Not every axis needs the full diff — some work better by selectively inspecting commits or specific files.

### How to discover local context (sub-agent responsibility)

Sub-agents discover their own axis-specific context from the filesystem and git history. The orchestrator does NOT do this work for you.

| What you need | Where to find it |
|---|---|
| Convention/style files | `.kiro/steering/*.md`, `CONTRIBUTING.md`, `STYLE.md`, `.editorconfig`, linter configs |
| Requirements / PRD | `docs/`, `specs/`, `.kiro/specs/`, issue links in commit messages |
| Issue/ticket references | `git -P log @{upstream}..HEAD` — look for `#123`, `Closes #`, SIM links, Taskei links |
| Type definitions / interfaces | Adjacent to changed files (use `--name-only` to find changed files, then explore) |
| Background context | `background-context.md` in repo root if it exists |

Each axis sub-skill specifies what context is relevant. Discover it yourself.

---

## Remote Mode Input

In remote mode, you are reviewing an existing CR/PR hosted on code.amazon.com or GitHub. There is NO local git repository. You MUST NOT run git commands.

### Diff content (inline)

The orchestrator provides the full unified diff directly in your prompt. This is the changeset under review — you do not need to fetch it.

### CR/PR metadata

The orchestrator provides metadata from the review platform:
- **Title** — the CR/PR title (equivalent to a commit message subject)
- **Description** — the CR/PR description body
- **Linked issues** — any tickets, SIM links, or issue references extracted from the CR/PR

These serve the same role that commit messages and issue links serve in local mode.

### Platform context

The orchestrator tells you which platform you're on:
- Platform: `CRUX` or `GitHub`
- Repository/package name
- Base branch

### How to access code (remote mode)

If you need to read a file beyond what's in the diff (for surrounding context, callers, type definitions):

**CRUX:**
```
mcp_builder_mcp_readinternalwebsites with URL:
code.amazon.com/packages/<REPO>/blobs/<BRANCH>/--/<PATH>
```

**GitHub:**
```
mcp_github_get_file_contents with:
owner=<owner>, repo=<repo>, path=<path>, ref=<base-branch>
```

Use these sparingly — the diff should contain enough for most findings. Fetch surrounding context only when needed to verify a concern (e.g., checking whether a function has other callers, or confirming a type definition).

### Context discovery in remote mode

You do NOT have filesystem access. Convention files, linter configs, and requirements docs can only be accessed via the platform-specific file-read recipe above. Check for them the same way you would in local mode, but using the API instead of filesystem commands.

---

## Rules for sub-agents

1. **Local mode: Run the diff command yourself.** The orchestrator does not pass diff content inline.
2. **Remote mode: Diff is provided inline.** Do NOT run git commands — there is no local clone. Use the platform-specific "read file" recipe if you need surrounding context.
3. **Be selective.** You don't have to load the entire diff if your axis only needs to inspect specific commits or files. In local mode, use `--name-only` first to triage.
4. **Use `-P` on all git commands (local mode only).** This prevents pagination from blocking execution.
5. **Do not modify the repository.** Read-only operations only. No commits, no checkouts, no stashes.
6. **Return output conforming to `OUTPUT-CONTRACT.md`.** The orchestrator parses your response mechanically.
