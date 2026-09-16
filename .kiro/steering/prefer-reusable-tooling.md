---
title: Prefer Reusable Tooling
inclusion: always
---

# Prefer Reusable Tooling

Tooling you write to do the work is governed here. Code you ship follows `clean-code.md`. The unit of value is a **durable tool**: one you invoke many times with different arguments, rather than many scripts you each write once.

## Check what exists before writing a script

List the current repo's `.agent-tools/` if you are in a repo, then `agent-context/agent-tools/`. Run `--help` on anything plausible.

## Build a durable tool when you will invoke it again

The signal is invocation count, not length. Build the tool when this shape of work will run three or more times with different inputs.

A script with hardcoded values solves one instance of the problem. If you can lift those values into input parameters without much extra work — a target path, a package name, a version, a date range — do that instead, and the same script serves the next agent who hits the problem. It is cheap at script one and expensive to retrofit: the alternative is v1 through v5 of near-identical scripts accumulating while you work the problem. When you are about to write the next variation, add a parameter to the original instead.

A script past ~100 lines is worth a second look, but that is a prompt to ask the question, not a threshold.

This satisfies `clean-code.md`'s ladder rather than excepting it: the future invocations are the second consumer, and one 400-line tool is less total code than five 180-line scripts.

## Prefer composable over monolithic

Follow the Unix philosophy: each tool does one thing well, reads from stdin or a file argument, writes structured output (NDJSON, one-per-line) to stdout, and sends progress to stderr. The composition point is the pipe.

A tool that queries an API, transforms the response, and writes a report is three tools. The signal that a tool is too broad: you want to reuse half of it but the other half is in the way. Split at that seam — smaller tools compose into pipelines the original author never planned, while a monolith only serves the workflow it was built for.

Hardcode nothing the caller could pass as input. A tool that accepts a package list from stdin serves both "scan these 5 packages" and "scan all 353" without a code change.

## Approval

- One-off script: proceed, this is inside autonomous scope.
- New durable tool: state the plan and wait. It introduces a pattern future agents depend on.
- New flag or subcommand on an existing tool: proceed.
- Changed behaviour of an existing flag or output: state the plan and wait. A future agent reads `--help` and invokes accordingly.

## Where tools live

| Scope | Location |
|---|---|
| Useful across repos | `agent-context/agent-tools/` |
| Coupled to one repo | that repo's `.agent-tools/` |

`.agent-tools/` sits at a git repo root, so a tool spanning several packages belongs in `agent-context/agent-tools/`. On first creating `.agent-tools/` in a repo, add it to that repo's `.git/info/exclude` — that keeps it out of `git status` and out of any code review without touching a tracked `.gitignore`.

When a second repo needs a `.agent-tools/` tool, move it to `agent-context/agent-tools/` and generalize it. Copying leaves two tools whose `--help` will disagree.

## Conventions

Every durable tool parses arguments and answers `--help`.

Python suits data, analysis, and source rewriting; bash suits driving builds and wrapping other CLIs. Use whichever fits.

## Related

See also: `clean-code.md` (the dependency ladder this satisfies), `human-in-the-loop.md` (approval scope; durable vs. transient writes).
