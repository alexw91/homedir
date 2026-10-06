---
name: write-commit-message
description: Generate Conventional Commits messages, with AI-assisted trailers, for uncommitted local changes in one or more git repositories. Use when user wants a commit message, asks to summarize changes, or mentions "commit message" or "write commit".
argument-hint: "Optional: one or more repo directory names or paths"
---

Generate git commit messages for local uncommitted changes (staged and/or unstaged) in one or more repositories. Output ONLY the commit message text — do NOT run `git add` or `git commit`.

## Workflow

1. **Identify repositories.** Use this priority order:
   - If the user provided repo names/paths as arguments, use those.
   - If no argument was given, prefer the repository that was most recently worked on in the current conversation (i.e., the last repo where files were read or edited earlier in this session).
   - As a last resort, detect the git repo for the current working directory.
   
   Repos may be:
   - Subdirectories under a workspace `src/` folder (monorepo packages)
   - Standalone repos elsewhere in the filesystem
   - The workspace root itself

2. **For each repository**, run:
   ```bash
   git -P -C <repo_path> diff HEAD
   ```
   If that returns nothing (no changes at all), also try:
   ```bash
   git -P -C <repo_path> diff --cached
   ```
   and:
   ```bash
   git -P -C <repo_path> diff
   ```
   to capture both staged and unstaged changes. Also check for untracked files:
   ```bash
   git -P -C <repo_path> status --short
   ```

3. **Analyze the diff** to understand what changed semantically. Read relevant surrounding code if needed for context.

4. **Write the commit message** following Conventional Commits format:

   ```
   <type>(<scope>): <subject>

   [optional body]

   [optional footer(s)]
   ```

   **Rules:**
   - `type`: one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`
   - `scope`: component or module affected (optional but preferred)
   - `subject`: imperative mood, no period, max 50 chars
   - `body`: explain *what* and *why*, wrap at 72 chars
   - Footer: breaking changes as `BREAKING-CHANGE: ...` — the hyphenated form, because the spaced `BREAKING CHANGE:` stops git from parsing every trailer in its block

   **Write diegetically.** The message describes the commit's own content and nothing outside it. A reader with only this diff must find every noun in the message inside that diff.

   - Describe only files the commit touches. Never mention files you considered and left out, excluded, or deferred — a reader cannot see them in the diff, so the reference is unresolvable.
   - Don't compare to the source the change came from. "Adds 156 lines over the source handoff" or "byte-identical to its source" describes a comparison the reader can't make; state what the committed file now contains.
   - Drop the selection process. How the change set was chosen (which variant won, what the filter was, how many candidates there were) is drafting history, not commit content.
   - Name the staging state nowhere. Whether a hunk is staged, and any out-of-scope working-tree changes, belong in your reply to the user, not in the message.

   **AI-assisted trailers.** End every message with these two trailers unless the user asks to leave them out:

   ```
   X-AI-Prompt: <one-line summary of the user's prompt>
   X-AI-Tool: <AI model name>
   ```

   - `X-AI-Prompt`: the request that produced this change, paraphrased in one imperative line of at most 72 chars. Summarize the intent; secrets, credentials, and personal data from the prompt stay out.
   - `X-AI-Tool`: the model name exactly as your session context reports it (e.g. `Claude Opus 5.5`). If the context does not name the model, ask the user.
   - Placement: the final paragraph, after one blank line, sharing a single block with every other footer (`BREAKING-CHANGE:`, `Refs:`) with no blank lines inside it. Git reads only the last paragraph as trailers.
   - If the repository's contributing docs prescribe a different AI attribution trailer (such as the Linux kernel's `Assisted-by:`), use theirs.
   - AI credit lives only in these trailers; `Co-authored-by:` and `Signed-off-by:` stay reserved for humans.

5. **Check the trailers parse.** Pipe each message through git; done when both `X-AI-` trailers appear in the output:
   ```bash
   git interpret-trailers --parse <<'EOF'
   <full commit message>
   EOF
   ```

6. **Print the message to stdout.** Use the condensed output format below. The repo path goes in a markdown header, followed immediately by the commit message in a fenced code block.

## Output Format

```
## Repo: /fully/qualified/path/to/repo

\`\`\`
<type>(<scope>): <subject>

<body>

X-AI-Prompt: <one-line summary of the user's prompt>
X-AI-Tool: <AI model name>
\`\`\`
```

If changes span multiple logical units within a single repo, output multiple fenced code blocks under the same heading. If multiple repos have changes, output one `## Repo:` section per repo.

## Important Constraints

- NEVER run `git add`, `git commit`, or `git push`
- Only describe uncommitted changes — ignore already-committed history
- Keep the message diegetic: every file and fact it names must be present in this commit's diff (see "Write diegetically" under step 4). Context outside the commit — excluded files, source comparisons, staging state — goes in your reply, not the message.
- If there are no uncommitted changes in a repo, say so and skip it
- If changes span multiple logical units, suggest multiple commits with separate messages
- Keep subject lines concise; put details in the body

## Example Output

For a single repo:

## Repo: /Users/aweibel/workspace/github/s2n

```
feat(auth): Add OAuth2 token refresh on expiry

Implement automatic token refresh when the access token expires during
an API call. The refresh is attempted once before failing the request.
Adds retry logic to the HTTP client middleware.

X-AI-Prompt: Refresh expired OAuth2 tokens before failing API calls
X-AI-Tool: Claude Opus 5.5
```

For multiple repos:

## Repo: /Users/aweibel/workspace/my-monorepo/src/PackageA

```
fix(handler): Correct null check on empty response body

The handler was not guarding against null response bodies when the
upstream returned 204 No Content, causing a NullPointerException.

X-AI-Prompt: Fix the NullPointerException on 204 responses and test it
X-AI-Tool: Claude Opus 5.5
```

## Repo: /Users/aweibel/workspace/my-monorepo/src/PackageB

```
test(handler): Add coverage for 204 No Content responses

X-AI-Prompt: Fix the NullPointerException on 204 responses and test it
X-AI-Tool: Claude Opus 5.5
```
