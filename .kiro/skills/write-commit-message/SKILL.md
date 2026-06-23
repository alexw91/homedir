---
name: write-commit-message
description: Generate Conventional Commits messages for uncommitted local changes in one or more git repositories. Use when user wants a commit message, asks to summarize changes, or mentions "commit message" or "write commit".
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
   - Footer: breaking changes as `BREAKING CHANGE: ...`

5. **Print the message to stdout.** Use the condensed output format below. The repo path goes in a markdown header, followed immediately by the commit message in a fenced code block.

## Output Format

```
## Repo: /fully/qualified/path/to/repo

\`\`\`
<type>(<scope>): <subject>

<body>
\`\`\`
```

If changes span multiple logical units within a single repo, output multiple fenced code blocks under the same heading. If multiple repos have changes, output one `## Repo:` section per repo.

## Important Constraints

- NEVER run `git add`, `git commit`, or `git push`
- Only describe uncommitted changes — ignore already-committed history
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
```

For multiple repos:

## Repo: /Users/aweibel/workspace/brazil/my-workspace/src/PackageA

```
fix(handler): Correct null check on empty response body

The handler was not guarding against null response bodies when the
upstream returned 204 No Content, causing a NullPointerException.
```

## Repo: /Users/aweibel/workspace/brazil/my-workspace/src/PackageB

```
test(handler): Add coverage for 204 No Content responses
```
