# Self-Contained Review (Sub-skill)

Review the changeset as if you are a fresh human reviewer opening a code review. You can see only what's in the diff. Every reference in the code — every name, comment, path, and commit message — should either resolve to something within the diff, something in the codebase at HEAD, or a well-known external concept. Anything else is a dangling reference that will send the reviewer on a wild goose chase.

## Core Question

**"If a human reviewer sees only what's in this CR, will anything confuse them or send them hunting for something that doesn't exist?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P show <sha>` for any committed change, and `git -P diff HEAD` for uncommitted changes. Focus on commits where the subject line or changed files suggest potential issues.

**Remote mode:** The diff is provided inline in your prompt. CR/PR metadata (title, description) serves the same role as commit messages. Use the platform-specific file-read recipe if you need surrounding context.

## Findings Catalog

1. `abandoned-ref:` - **Does this reference something from the development process that isn't in the final changeset?** Comments that reference approaches not taken ("Replaced from X", "Previously tried Y", "Unlike the old approach…"). These are diary entries for the author, not documentation for the reader. The final code should stand alone without explaining its own development history. Remove it. Verdict ≥ 8: `FIX REQUIRED`.

2. `wip:` - **Is this unfinished work?** TODO/FIXME markers, `console.log`/`printf` debug statements, commented-out code from earlier experiments, placeholder implementations (functions that return hardcoded values with a note to "implement later"). These signal the work isn't finished. Either finish the work or remove the marker. Exception: intentional scope-limiting TODOs ("TODO(next-CR): add pagination") are communication to the reviewer, not WIP debris. Verdict ≥ 8: `FIX REQUIRED`.

3. `message-mismatch:` - **Does the commit message match the code?** A commit message that mentions a concept, ticket, branch, or approach that isn't visible in the diff, or claims the code does X but the diff actually does Y. The reviewer will read the message first, form an expectation, then be confused when the code doesn't match. Rewrite the message to describe what the code actually does. Verdict ≥ 8: `FIX REQUIRED`.

4. `local-path:` - **Are there hardcoded local environment values?** Hardcoded paths (`/Users/...`, `/home/...`, `/tmp/debug/...`), machine-specific hostnames, local port numbers in non-test code, references to local-only tools or scripts not checked in. Will break on any other machine. Verdict ≥ 8: `FIX REQUIRED`.

5. `phantom:` - **Does this reference something that doesn't exist?** Code that imports, references, or calls something that doesn't exist in the diff or in the codebase at HEAD. Often a leftover from an abandoned approach where a helper function was deleted but its call site remained. Also: comments referencing specific commits in other repos, branches that don't exist, or other artifacts the reviewer cannot see. This will break or confuse. Verdict ≥ 8: `FIX REQUIRED`.

6. `vestigial-name:` - **Does this name reflect a previous implementation?** Variable names, function names, file names, or test names that reflect an earlier implementation approach rather than the current one. Example: a function named `tryFallbackParser` that no longer falls back to anything. The name lies about what the code does. Might be an intentional name choice the reviewer should weigh in on. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `narrative:` - **Does this comment narrate the development process?** Comments that narrate the development process rather than documenting the code: "After discussion with the agent, we decided…", "Approach 3 of 5", "This is cleaner than the previous version". Development diaries belong in commit messages or handoff docs, not in source code. Also: tests describing what the code *used to do* rather than what it does now. Verdict ≥ 8: `FIX REQUIRED`.

8. `cross-ref:` - **Does this reference something the reviewer can't access?** Code or comments that reference specific commits in other repositories, branches that don't exist in this repo, or other changesets the reviewer cannot see from this code review alone. Exception: references to well-known external projects (e.g., "per RFC 8446 section 4.2") are fine. Might be intentional documentation of an external dependency. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what's wrong>. → <fix>.
```

For commit-message-level findings:

```
[<confidence 1-10>] commit <short-sha>: <tag> <what's wrong>. → <fix>.
```

## Confidence Calibration (Self-Contained axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** A comment explicitly says "replaced from approach X" or "previously tried Y" — textbook abandoned-ref. Or: a hardcoded `/Users/username/` path. Or: an import of a module that provably doesn't exist.
- **9:** A commit message says "add retry logic" but the diff contains no retry logic whatsoever.
- **8:** A function named `tryFallbackParser` that contains no fallback mechanism. Or: `// TODO: implement` in production code.
- **6-7:** A comment that *might* be referencing an abandoned approach but could also be legitimate documentation of a design decision.
- **4-5:** A variable name that seems slightly off but could be intentional. A commit message that's vague but not wrong.
- **2-3:** Extremely minor — a comment that's slightly more narrative than necessary but not confusing.
- **1:** Pure style preference about how to phrase a commit message.

## Rules

- **Local mode:** Run `git -P show <sha>` for any commit where the subject line raises suspicion (vague messages like "WIP", "fixup", "cleanup"; messages that mention concepts you want to verify are present in the diff).
- **Local mode:** Run `git -P diff HEAD` to inspect uncommitted changes — these are the most likely to contain WIP remnants since they haven't been intentionally committed yet.
- **Remote mode:** Work from the inline diff and CR/PR metadata provided. Use the platform file-read recipe for surrounding context if needed.
- Do NOT flag legitimate external references (RFCs, well-known library documentation, issue tracker links that are standard CR metadata).
- Do NOT flag TODO comments that are clearly intentional scope-limiting ("TODO(next-CR): add pagination") — these are communication to the reviewer, not WIP debris. Flag only TODOs that look like forgotten work.
- Do NOT flag commit messages that reference the issue being solved (e.g., "Fixes #123") — these are standard CR metadata.
- The test for every finding: "Would a fresh reviewer reading only this diff be confused by this, or would they go looking for something that doesn't exist here?"

## Boundaries

- **vs Clean:** The Clean axis has `mixed-scope:` (unrelated changes bundled) and `stale-doc:` (docs describing old behavior). This axis owns the broader category of "reviewer confusion caused by development process artifacts leaking into the final product." If something would confuse a reviewer because it references the *process* rather than the *product*, it belongs here. If it's simply outdated documentation about the code's behavior, it belongs to Clean.
- **vs Style:** Commit message formatting (capitalization, line length, conventional-commits compliance) belongs to Style. Commit message *accuracy* (does the message match the code?) belongs here.
