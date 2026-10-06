# Diegetic pattern catalog

Judge each passage by its role in the artifact. The same phrase can be diegetic in one genre and residue in another. A migration guide needs version comparisons; a reference manual usually does not.

## Contents

- [Finding classes](#finding-classes)
- [Residue patterns](#residue-patterns)
- [Genre boundaries](#genre-boundaries)
- [Provenance replacement order](#provenance-replacement-order)
- [Output examples](#output-examples)

## Finding classes

- **Blocking:** An inaccessible source or LLM session is the only provenance for a claim. Remove the claim from the artifact and preserve it in the external blocking list until an accessible source replaces it.
- **Rewrite:** Language can adopt the artifact's viewpoint without changing information or behavior.
- **Structural:** An identifier, abstraction, API, compatibility label, or code path records development history. Report it separately for approval.
- **Keep:** The passage belongs to the artifact's genre, audience, or present state.

## Residue patterns

### 1. Draft history

Draft history describes the document's revisions instead of its subject.

**Watch for:** in this draft, in this revision, the previous version, this section was added, updated above, as rewritten.

**Before:**
> In this revision, we added a table that lists each supported protocol.

**After:**
> The table lists each supported protocol.

**Keep when:** the artifact is a changelog, release note, migration guide, or version comparison and the revision is its subject.

### 2. Authoring process

Authoring process narrates how the writer or agent reached the text rather than giving the resulting evidence or conclusion.

**Watch for:** after reviewing, I was asked to, we searched, the following was generated, during this analysis, I then read.

**Before:**
> After reviewing the configuration, I found that the listener uses TLS 1.3.

**After:**
> The listener uses TLS 1.3.

**Keep when:** the method is evidence readers must trust or repeat, such as an experiment, benchmark methodology, or incident investigation procedure. State the repeatable method, not the writer's journey through it.

### 3. Reader or reviewer coordination

Coordination residue addresses the document's production workflow rather than its intended reader.

**Watch for:** for the reviewer, please approve, TODO before publishing, expand this later, insert diagram here, verify before sending.

**Before:**
> For the reviewer: please confirm whether the timeout should remain 30 seconds.

**After:**
> The timeout decision remains open.

Use an external blocker or decision request when the issue must be resolved before publication. Direct reader instructions remain diegetic in procedures, tutorials, forms, and operational runbooks.

### 4. Unseen comparisons

Unseen comparisons assume access to an earlier implementation or draft that the audience cannot inspect.

**Watch for:** the new approach, cleaner than before, unlike the old implementation, now supports, was changed to, no longer.

**Before:**
> The new implementation uses a map instead of the old loop.

**After:**
> The implementation uses a map instead of iterating through all entries.

**Keep when:** the old and new states are both part of the artifact's subject, as in migration guides, changelogs, compatibility notes, or decision records.

### 5. Production scaffolding

Scaffolding belongs to drafting or local production rather than the finished artifact.

**Watch for:** placeholder copy, prompt text, drafting notes, absolute workstation paths, temporary section labels, pasted chat instructions, and references to material that will not ship with the artifact.

A TODO or FIXME tied to real unfinished work is part of a codebase's present state. A note such as `TODO: explain this before review` is drafting residue. `LegacyMode` is valid when it names a compatibility contract; it is structural when it only records implementation history.

### 6. Inaccessible references

A reference is diegetic only when the intended audience can follow it.

| Reference | Default treatment |
|---|---|
| Public durable URL for a public audience | Keep |
| Internal durable URL for an internal audience | Keep |
| Repository-relative path that ships with the artifact | Keep |
| Absolute local path | Remove or replace |
| Scratch file or private note | Remove or replace |
| `agent-context/handoffs/` or another agent-only artifact | Remove or replace in review and publication documents |
| Session transcript, chat link, or session identifier | Remove from durable artifacts |

A heading such as `Previous related documents` does not justify inaccessible links. Replace each link with an accessible primary source when one exists. If the local document is the only evidence for a claim, move the claim to `Blocking`; removing only the citation would launder the claim into an unsupported assertion.

### 7. LLM session residue

Session residue makes a durable artifact depend on an ephemeral execution context.

**Watch for:** this session, read the session, the agent found, Kiro generated, prompt used, conversation above, handoff from the previous agent.

**Before:**
> The failure is confirmed from the build logs; read this session.

**Result:**
Remove the sentence unless an accessible build log supports it. Record the omitted claim under `Blocking` with the inaccessible session reference kept outside the artifact for the author's use.

Session references belong in artifacts whose purpose is session tracking, such as handoffs, execution logs, and transcript indexes.

## Genre boundaries

| Genre | History or process that belongs |
|---|---|
| Changelog or release notes | Changes, versions, dates, and prior behavior |
| Migration guide | Explicit old/new comparison and ordered transition steps |
| Architecture Decision Record | Decision context, considered options, and reasons for rejection |
| Design or decision document | Evidence, alternatives readers may weigh, and durable related documents |
| Postmortem or Correction of Error | Incident chronology, investigative method when evidentiary, and corrective actions |
| Procedure or runbook | Direct reader instructions and repeatable commands |
| Handoff or execution log | Session and work history required for continuation |
| Reference documentation | Present behavior, contracts, constraints, and examples |
| Code comment | Local invariant, rationale, contract, or externally meaningful history |

The genre permits only history that serves its purpose. A design document may explain rejected alternatives, but its `Previous related documents` section still excludes local handoffs that reviewers cannot access.

## Provenance replacement order

Prefer the first accessible source available:

1. a canonical primary source already named in the input;
2. a durable primary source available to the intended audience;
3. a repository-relative source that ships with the artifact;
4. an external `Blocking` entry when no accessible source exists.

Search sources already available in the workspace or supplied context before declaring a blocker. Do not invent a replacement citation or broaden a source beyond what it supports.

## Output examples

### Rewrite with no blocker

**Source:**
> We added the four-byte check after incident INC-42. Unlike the old code, it checks `len < 4` before reading the integer.

**Artifact:**
> A four-byte integer requires `len >= 4` before it is read. Incident INC-42 records the requirement's origin.

`INC-42` survives only if the intended audience can access it and that history helps the artifact's genre. Otherwise retain the invariant and remove the incident reference.

### Rewrite with a blocker

**Source:**
> The failure is confirmed from the build logs; read this session. Previous related document: `/Users/me/workspace/agent-context/handoffs/run.md`.

**Artifact:**
> *(The unsupported claim is omitted.)*

**Removed references:**
- Local handoff: `/Users/me/workspace/agent-context/handoffs/run.md`
- LLM session reference

**Blocking:**
- Claim: "The failure is confirmed from the build logs."
- Needed: an accessible build log that directly supports the claim

### Detect mode

> "Cleaner than the previous draft."

- **Rewrite — Unseen comparison:** The sentence evaluates an unavailable draft instead of describing the current artifact.
