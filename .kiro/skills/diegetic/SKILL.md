---
name: diegetic
description: Makes documents, code comments, and other text speak from inside the artifact's own world by removing drafting history, authoring process, LLM session residue, inaccessible local references, reviewer coordination, unseen comparisons, and production scaffolding. Use when the user asks for a diegetic, self-contained, or publication-ready artifact; asks to audit or rewrite text or a codebase for drafting and process residue; needs content independent of local or session context; or when another skill requests a diegetic pass.
---

# Diegetic

## Overview

A diegetic artifact describes its subject from inside the artifact's own world. It states what exists, what happens, what was decided, or what evidence shows.

## Usage

Use this skill when:

- rewriting an artifact to remove drafting, authoring, session, or reviewer residue;
- auditing text or a codebase for language that depends on unseen history or inaccessible context; or
- preparing self-contained material for review or publication.

Read [PATTERNS.md](PATTERNS.md) before auditing or rewriting. It defines the residue patterns, genre exceptions, audience test, and finding classes.

## Core Concepts

- **Artifact world:** State what exists, happens, was decided, or is supported by evidence.
- **Genre boundary:** Preserve history and process when the artifact's genre requires them. Change history belongs in a changelog, incident chronology in a postmortem, and direct instructions in a procedure.
- **Audience boundary:** Keep every reference accessible to the intended audience.
- **Provenance boundary:** Express evidence as a durable source, command, test, code location, or observed result rather than an LLM session or private workspace artifact.
- **Preservation:** Preserve information, behavior, and public contracts rather than sentence order or document shape.
- **Skill boundary:** Keep `humanizer` separate. When both passes are requested, run `diegetic` first.

## Workflow

1. **Establish the world.** Identify the artifact, its genre, and its intended audience. Use the user's explicit audience, then an audience named by the artifact, then its genre and destination. Ask only when the answer would change an edit.
2. **Classify candidates.** Account for every candidate from `PATTERNS.md` as `Keep`, `Rewrite`, `Blocking`, or `Structural`.
3. **Resolve provenance.** Replace an inaccessible reference with an accessible primary source when available. When the inaccessible source is the only support for a claim, remove the claim from the artifact and copy it into the external blocking list.
4. **Reshape the artifact.** Merge, split, move, or delete scaffolding as needed. State the surviving claims directly from the artifact's viewpoint.
5. **Audit preservation.** Compare source and result. Every original claim must survive, gain an accessible replacement source, or appear in the blocking list. Never invent a fact, source, result, path, or rationale.
6. **Apply the completion contract.** Finish only when every check below passes.

## Modes

### Rewrite mode

For pasted text, return:

1. the transformed artifact;
2. a compact list of removed non-diegetic references; and
3. a `Blocking` list for claims awaiting accessible evidence.

For a file, follow the applicable file-version and approval policy. When none exists, propose the rewrite before replacing a durable document. Report the removed references and blockers outside the artifact.

For embedded use, return only the transformed artifact when no blockers exist. When blockers exist, return the artifact and a structured `Blocking` list to the parent workflow.

### Detect mode

When the user asks for an audit or diagnosis, quote each offending passage, assign its finding class and pattern, and state which artifact boundary it violates. Leave the artifact unchanged.

### Codebase mode

Audit before editing. Rank every finding and separate language rewrites from structural candidates. Wait for approval of the file scope before changing multiple files.

Language rewrites may cover documentation, comments, diagnostics, fixtures, and user-facing text. Identifiers, abstractions, compatibility labels, APIs, behavior, build data, and control flow are structural candidates unless the user explicitly approves them.

## Completion contract

A diegetic pass is complete only when every check passes. If a check fails, return to the relevant workflow step and repeat the audit after the fix:

1. Every surviving sentence belongs to the artifact's world or is required by its genre.
2. Every reference is accessible to the intended audience.
3. No durable artifact depends on an LLM session, prompt, handoff, scratch file, or local-only path.
4. Every original claim survives, has an accessible replacement source, or appears in `Blocking`.
5. Code behavior and public contracts remain unchanged.
6. Structural candidates remain separate and unedited without explicit approval.
