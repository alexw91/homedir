---
name: plain-english-technical-doc
description: Rewrite a technical document as a new plain-English sibling file, written by a fresh-context subagent that keeps the original's structure, facts, and accurate terms while removing jargon. Use when asked for a plain-English, less jargony, or easier-to-follow version of an existing doc for the average software engineer.
argument-hint: "Path to the document to rewrite, and optionally the target reader (default: the average software engineer)"
---

# Plain-English technical doc

## Overview

This skill turns an existing technical document into a **plain-English sibling**: a new file next to the source, with the same spine and the same facts, readable on first pass by an engineer who does not know the subject's vocabulary. The source stays byte-identical.

You are the **orchestrator**. A fresh subagent is the **rewriter**. The split exists because you already understand the subject, so the passages that confuse a newcomer read as clear to you. The rewriter arrives cold, *stumbles* where a real reader would, and rewrites exactly those passages. Your job is to protect that cold read: hand over paths and the reader profile, never your understanding of the subject.

## Usage

Run when the user names a document and asks for a plain-English, simpler-to-read, or less jargony version. To edit, shorten, or restructure a document in place, use `simplify-doc` instead.

Inputs:

- **SOURCE**: absolute path to the existing document.
- **READER**: the target reader. Default: "the average software engineer: knows git, code review, and common cloud services; does not know this team's systems, tools, or shorthand."
- **REQUEST**: the user's request, verbatim. The rewriter quotes it in an AI disclosure when the source carries one.

## Core Concepts

- **Plain-English sibling**: the new document. Same section order, argument, tables, diagrams, findings, and evidence as the source; simpler words and sentences; every term defined before use.
- **Cold read**: the rewriter's first pass through the source, done before it opens any other material. Its confusion is the input that drives the rewrite.
- **Stumble**: a place the cold reader had to reread, guess, or look something up. Each one is a rewrite target.
- **Accurate term**: a canonical name a reader would search for (a package, file, flag, AWS service, or the domain's established word). Keep it and define it on first use. Team shorthand, coined labels, and metaphors are jargon: replace them with literal phrasing.

## Steps

### 1. Pin the paths

1. Resolve SOURCE to an absolute path and confirm it exists with a directory listing. Leave reading its content to the rewriter.
2. Choose **OUTPUT** in the same directory as SOURCE:
   - If the directory follows the `handoff` storage convention (`YYYY-MM-DD.NN - Title.TYPE.md`), use today's date, the next unused `NN`, a new descriptive title, and the source's `TYPE`.
   - Otherwise, use `<source stem>.plain-english<source extension>`.
3. Confirm OUTPUT does not already exist. If it does, ask the user before choosing another name.
4. Record the source checksum: `shasum -a 256 "<SOURCE>"`.

**Completion criterion:** SOURCE and OUTPUT are absolute paths, OUTPUT is unused, and the checksum is recorded.

### 2. Dispatch the rewriter

Start one fresh-context subagent on the strongest model available, at high reasoning effort. Use a mechanism that creates a real context boundary: `run_workflow` with `workflowPath: "agent://wf-coder"` and the prompt below as its `prompt` input, or `invoke_sub_agent` where that tool exists. An `agent://` launch inherits this session's model, so confirm the session runs a high-end model, or ask the user which one to use. Calling another skill inline is not a dispatch, because it shares this context.

Send exactly this prompt, filling the placeholders and nothing else:

```text
You are rewriting a technical document into a plain-English sibling.

SOURCE (read-only): <SOURCE>
OUTPUT (create this file, and write only here): <OUTPUT>
READER: <READER>
USER REQUEST (verbatim, for any AI disclosure): <REQUEST>

Read <absolute path of this skill's directory>/REWRITER.md and follow every step in it.
Return the report that REWRITER.md specifies.
```

The prompt carries no summary, background, or explanation of the subject. Anything you add about the subject gives the rewriter your understanding and cancels the cold read.

**Completion criterion:** the subagent is running with the filled-in prompt, and the prompt contains no description of the subject.

### 3. Verify the result

When the subagent finishes:

1. Re-run `shasum -a 256 "<SOURCE>"`. It must match the recorded checksum. If it differs, stop and tell the user the source changed. If the source is tracked in git, show `git -P diff -- "<SOURCE>"` and propose a restore, but wait for approval before running it.
2. Confirm OUTPUT exists and is non-empty.
3. Confirm the report contains every section REWRITER.md requires.

**Completion criterion:** the checksum matches, OUTPUT exists, and the report is complete.

### 4. Report to the user

Give the user:

1. The OUTPUT path.
2. Every **correction** the rewriter applied: a fact in the source that a primary source contradicted, with the evidence. Corrections change facts, so the user decides whether they stand.
3. Every stumble the rewriter left **unresolved**.
4. A one-line summary of the stumble log and the preservation check.

**Completion criterion:** the user has the path, every correction with its evidence, and every unresolved stumble.
