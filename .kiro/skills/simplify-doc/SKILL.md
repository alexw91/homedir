---
name: simplify-doc
description: Reduce a technical document's cognitive load without losing claims, caveats, evidence, or operational detail. Use when asked to simplify or shorten a document, make a handoff easier to scan, remove repeated or competing concepts, or replace complex prose with a diagram.
---

# Simplify document

## Overview

Make the document easier to understand and act on. Preserve its accuracy, evidence, constraints, and voice. Shorter is useful only when the reader has less work to do.

The simplified document must stand on its own. Remove repetition, weak branches, and sentence-level friction before compressing explanations that readers need.

## Usage

Use this skill for technical handoffs, design documents, decision documents, runbooks, reference material, and other prose-heavy technical artifacts.

Choose the mode from the user's request:

- **Review mode:** Identify simplification opportunities without changing the document.
- **Rewrite mode:** Return simplified pasted text.
- **File mode:** Edit the named file only when the user explicitly asks to simplify or rewrite it. Keep the change report outside the artifact.

If the intended audience or reader outcome is unclear and the answer would change what survives, ask one question before editing. Recommend the most likely answer.

## Core concepts

- **Reader outcome:** What the reader must know, decide, or do after reading.
- **Spine:** The shortest complete path from the opening to the reader outcome.
- **Protected content:** Claims, evidence, caveats, warnings, decisions, open questions, numbers, dates, identifiers, links, code, commands, and acceptance criteria that must survive unless the user approves their removal.
- **Concept load:** The number of ideas a reader must hold at once. Reduce it by sequencing, co-locating, or disclosing ideas, not by deleting required distinctions.
- **Net simplification:** An edit reduces the reader's work after accounting for any new headings, cross-references, diagrams, captions, or exceptions it introduces.

## Workflow

Run the passes in order. Structural edits make later sentence edits cheaper and safer.

### 1. Establish the contract

Record these before editing:

1. Artifact genre.
2. Intended audience and what they already know.
3. Reader outcome.
4. Content that must remain exact.
5. Output mode and destination.

Infer these from the document when the evidence is clear. Ask only when different answers would produce materially different edits.

For a change to another team's system, preserve a brief current-state explanation before the proposed change. The owning team must be able to verify the shared model before considering the proposal.

**Completion criterion:** The reader outcome is one sentence, and every item that must remain exact is listed or classified.

### 2. Build a preservation ledger

Inventory the source before rewriting. Track protected content at the smallest useful unit:

- factual claims and their cited support;
- numbers, dates, rankings, and thresholds;
- decisions, asks, owners, risks, and open questions;
- warnings, exceptions, prerequisites, and failure behavior;
- code blocks, commands, identifiers, links, quotations, and table data.

Do not treat sentence order as protected. Preserve information, not shape. Leave code, commands, canonical identifiers, URLs, and quoted text unchanged unless the user requested a correction backed by evidence.

If an inaccessible source is the only support for a claim, remove the claim from the artifact and report it under `Blocking`. Do not turn an unsupported claim into an uncited assertion.

**Completion criterion:** Every source section maps to protected content or is explicitly marked as removable scaffolding.

### 3. Recover the spine

Write a one-line outline of the argument or procedure. Reorder the document so the reader reaches the outcome with the fewest unresolved dependencies:

- Put the conclusion, decision, ask, or task first.
- Order procedures by execution sequence.
- Put general behavior before exceptions.
- Introduce each concept before a later section depends on it.
- Keep a concept's definition, rules, and caveats together.
- Move optional depth behind a descriptive heading, appendix, or durable link.

Delete headings that divide one continuous idea. Add headings only when they help a reader predict or skip the material below them.

**Completion criterion:** Every surviving section has one job in the reader's path, and changing the section order would break that path.

### 4. Delete sentence by sentence

Test every sentence. Keep it only if it does at least one job:

1. Advances the reader toward the outcome.
2. Defines a concept needed later.
3. Supports or qualifies a claim.
4. States a constraint, risk, exception, or decision.
5. Tells the reader what to do.
6. Provides navigation that saves more work than it adds.

Delete the whole sentence when it does none of these. Do not polish a sentence whose meaning should disappear.

When two passages make the same point, keep the clearer and better-supported version in the place where the reader first needs it. Replace later repetition with nothing, or with a short pointer when the reader must return to the detail.

Preserve intentional repetition in safety instructions, critical prerequisites, summaries used independently, and repeated table headers.

**Completion criterion:** Every surviving sentence has a named job, and each meaning has one authoritative home unless repetition serves a concrete safety or navigation need.

### 5. Reduce concept load

Review each paragraph and section for competing ideas:

- Give each sentence one idea and each paragraph one topic.
- Split a paragraph when its ideas must be understood at different times.
- Merge fragments when separating them forces the reader to reconstruct one idea.
- Use one established term for one concept. Remove synonym cycling.
- Move specialist detail to the point where it becomes necessary.
- Convert unordered comparisons to tables when readers must scan the same fields across items.
- Convert ordered actions to numbered steps.
- Remove an alternative when no intended reader would reasonably choose it.

Do not flatten distinctions that affect behavior, compatibility, ownership, risk, or a decision. A concept is removable only when it is duplicated, irrelevant to the reader outcome, or safely disclosed elsewhere.

**Completion criterion:** No paragraph requires the reader to resolve two unrelated questions, and no concept appears before the reader needs it.

### 6. Test visual substitution

Consider a Mermaid diagram when relationships create more load than the prose itself. Good candidates include request paths, actor interactions, state transitions, ownership boundaries, timelines, and decision branches.

Add a diagram only when all of these are true:

1. It answers one named reader question.
2. Its nodes and edges use concepts already supported by the source.
3. It replaces a substantial prose explanation instead of duplicating it.
4. A short caption states the takeaway.
5. The remaining prose carries details the diagram cannot express, such as caveats, evidence, and exact constraints.
6. The diagram renders successfully in the document's target environment.

Use the simplest fitting form:

- `flowchart` for paths, ownership, and decisions;
- `sequenceDiagram` for ordered interactions between actors;
- `stateDiagram-v2` for valid states and transitions;
- a table when exact comparison matters more than topology.

Keep one abstraction level per diagram. Label edges with the event or condition that matters. Remove decorative nodes and implementation detail that do not answer the named question.

A diagram must not become the only representation of information. Pair it with a concise textual equivalent that conveys the same relationships, and retain exact constraints in prose or a table.

**Completion criterion:** Each diagram replaces prose, renders, answers one question, and introduces no unsupported fact or relationship.

### 7. Tighten the prose

Apply sentence-level edits only after the structure is stable:

- Put the actor before the action when the actor is known.
- Prefer specific verbs and ordinary words.
- Replace vague pronouns with the established term.
- Remove throat-clearing, filler, performed rigor, and generic summaries.
- Turn buried conditions into direct `if`, `when`, or `only if` statements.
- Keep sentence length varied; split a sentence when it carries unrelated ideas.
- Preserve the author's technical register and deliberate voice.

Run `diegetic` before `humanizer` when both apply. Use `diegetic` to remove drafting and session residue. Use `humanizer` after preservation and structure checks so voice editing cannot hide a lost claim. Use `doc-review` logic checks when simplification changes the argument or removes an alternative.

**Completion criterion:** The prose reads naturally aloud, uses the same term for the same concept, and contains no sentence-level padding that survived only because it sounds polished.

### 8. Prove preservation and improvement

Compare the final document with the source. Do not rely on memory of the edit.

Verify:

1. Every ledger item survives unchanged in meaning, has an accessible replacement source, or appears under `Blocking`.
2. The rewrite adds no factual claim, relationship, rationale, number, date, identifier, citation, or ranking.
3. Code, commands, identifiers, links, quotations, warnings, and exact thresholds remain intact unless an approved change says otherwise.
4. Headings, lists, tables, links, and Mermaid blocks render.
5. Every cross-reference resolves after sections move or disappear.
6. Each diagram replaces rather than repeats prose.
7. The opening states the reader outcome.

Report word count before and after as evidence, not as the target. Also report sections removed, merged, moved, or disclosed. A smaller word count does not prove a simpler document.

**Completion criterion:** Every protected item is accounted for, every structural element works, and the final document requires fewer words, fewer concurrent concepts, or fewer navigation steps without reducing required detail.

## Output

### Review mode

Rank findings by expected reduction in reader effort:

```text
[IMPACT: high|medium|low] [SECTION]
Load: <what the reader must unnecessarily remember, infer, or reread>
Evidence: <short quote or structural reference>
Change: <delete, merge, move, disclose, diagram, or rewrite>
Preservation check: <what must survive>
```

End with the smallest high-impact edit the author can make first.

### Rewrite or file mode

Deliver the simplified artifact. Keep this compact report outside it:

```text
Simplification report
- Reader outcome: <one sentence>
- Words: <before> -> <after> (<percent change>)
- Structure: <sections removed, merged, moved, or disclosed>
- Visuals: <diagram added and prose replaced, or none>
- Preservation: <all protected items accounted for, or exceptions>
- Blocking: <unsupported claims awaiting accessible evidence, or none>
```

Do not insert the report, drafting notes, or a description of the editing process into the artifact.

## Guardrails

- Optimize for reader effort, not the smallest file.
- Keep orientation that a new reader needs, even when an expert could infer it.
- Do not replace precise technical terms with familiar but inaccurate words.
- Do not remove caveats because they interrupt the main narrative. Place them where they constrain the relevant claim.
- Do not hide operationally required detail behind a link.
- Do not invent transitions, causes, or relationships to make a diagram look complete.
- Stop and ask when two source passages conflict and choosing one would change the document's meaning.

## References

- [Google Technical Writing One summary](https://developers.google.com/tech-writing/one/summary): consistent terminology, specific verbs, one idea per sentence, one topic per paragraph, audience fit, and outcome-first openings.
- [Digital.gov plain-language organization guide](https://digital.gov/guides/plain-language/principles/organize): purpose and bottom line first, reader-question order, process order, and general cases before exceptions.
- [STE Plain Writing agent skill](https://github.com/Ryuketsukami/ste-plain-writing): preserve facts, warnings, constraints, and useful detail; use repeatable before-and-after checks rather than word bans alone.
- [W3C guidance for complex images](https://www.w3.org/WAI/tutorials/images/complex/): provide a text equivalent for the data or information conveyed by a diagram.

Content from external sources was rephrased for compliance with licensing restrictions.
