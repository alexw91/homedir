---
name: explainer-doc
description: Explainer — research a technology, system, protocol, or concept against primary sources and write a thorough, self-contained document explaining what it is and how it works. Use when asked for an explainer, a pedagogical deep-dive on how something works, or to extend an existing explainer with new research.
argument-hint: "Topic, plus optionally: what you already know about it, the systems to compare it with, specific questions, and an existing explainer to extend"
---

An explainer teaches one topic end to end. It runs `/research` to gather evidence, then writes a `/handoff` `reference` document from that evidence. Tone and prose rules live in `.kiro/steering/writing-tone-and-style.md` and already apply.

## The reader

Write for the **average software engineer** who could give a one- or two-sentence description of the topic and knows almost nothing past it. Keep that reader even when the requester is a world expert in the topic: the same document has to serve three uses.

- **Coworkers** learning the topic for the first time read it top to bottom.
- **Agents** use it as a reference. They search it for an identifier and need to land on that identifier's definition.
- **The expert** skims it to get back up to speed. They read the Summary table and Key Findings, then jump to one numbered section.

When in doubt, write more. A missing mechanism costs the reader a trip to the sources. An extra paragraph costs them a skip.

## Modes

Pick one mode from the request before starting:

- **Topic.** "Explain X", usually with what the requester already knows and a list of things to cover. Use the full coverage menu below.
- **Questions.** The request centers on specific questions, such as a planned feature, a migration path, or "when do I need to do Y". Each question becomes a required section. Then add the core coverage items so the answers have a model to rest on.
- **Extend.** The request names an existing explainer and asks for more depth or a new area. Research only the new items, then edit the document in place (step 6 covers what to reconcile).

## Steps

### 1. Frame the request

Write down, for your own use:

- **Topic**, named the way its owners name it.
- **Starting model**: the requester's one-line description ("I know that X is…"). If they gave none, write the one or two sentences the average engineer would say. Treat it as a claim to verify, not a fact. The Summary later confirms it, sharpens it, or corrects it.
- **Neighbors**: the systems the reader will confuse the topic with, or that it integrates with. Use the requester's list. If they gave none, choose three to six.
- **Requester's questions and emphasis** ("I'm especially interested in…"), kept verbatim.
- **Source scope**: public, internal, or both. Default to every primary source you can reach.
- **Destination**: the requester's named path, or the `/handoff` storage convention.

Read the request for meaning: prompts are often typed fast, so fix typos and misnamings when you interpret them. Depth defaults to thorough. Ask a question only when the topic itself is ambiguous, for example when two systems share a name. In a follow-up such as "now one on X", take the frame from the conversation and add the earlier explainer's topic to the neighbors.

The step is done when every field above has a value.

### 2. Plan the coverage

Select items from the coverage menu (below) and assign each one a numbered section. The step is done when every menu item is either in the plan or out with a one-line reason ("no history: the feature is unreleased"), and every requester question maps to a section.

### 3. Research

Run `/research` as parallel passes, one per cluster of related coverage items. Use two passes for a narrow topic and up to seven for a broad one. Give each pass:

- the topic, the starting model, and the neighbors;
- its coverage items, phrased as questions;
- the source scope, and the rule that every claim carries a link to the primary source that owns it (a spec, source code at a pinned commit or tag, the owning team's docs, a first-party API);
- a notes file under `temp/` for its findings.

The step is done when every planned item has findings with sources, or a recorded "no primary source found".

### 4. Verify the load-bearing claims

A **load-bearing claim** is one the reader's model depends on: a default, a limit, an ordering, a name, a date, a version, a quote, a count, or a statement of behavior. Re-read each one at its source before writing. Where passes disagree, the owning source decides.

- Reproduce behavior when it's cheap: a scratch project, a container, a local build, or a code example run with its real output captured. A reproduced behavior is stronger evidence than a sentence in a doc.
- For seven passes, or any topic where a wrong claim would mislead a design decision, also run a separate fact-check pass in a fresh context. It checks every claim, quote, and link against its source.
- Record what you couldn't confirm. It goes in the document's *Not verified* list.

The step is done when every load-bearing claim is confirmed, corrected, or listed as not verified.

### 5. Write

Follow [`TEMPLATE.md`](TEMPLATE.md) for the skeleton and the AI disclosure, together with the `/handoff` `reference` type and its completion contract. Within each section:

- Define every term before its first use, in dependency order. Name the canonical identifier in code font so an agent's search lands on its definition.
- Put the normal path before the edge cases and failure modes.
- Draw a Mermaid diagram for each structure or flow the prose describes: component boundaries, a lifecycle, an ordering. Introduce each one with the point it shows. Render-check every block.
- Show real artifacts: config snippets, API shapes, commands, and their output, copied from the source rather than reconstructed. Label anything you composed *Illustrative*.
- Label each conclusion the sources don't state as *Inference*, and each claim resting on a personal page or unofficial write-up as *Secondary*.
- Pin version-sensitive facts to their commit, tag, version, or measurement date.

The notes from steps 3 and 4 are working material. Cite the primary sources they found, never the notes.

### 6. Check

The document is done when every check passes:

1. A reader who stops after the Summary can restate the topic correctly in a paragraph, including any correction to the starting model.
2. A reader who reads everything can answer every planned coverage item and every requester question without opening a source.
3. Every term is defined before it's used, and every table explains its own columns and IDs.
4. Every factual claim cites an accessible primary source, or is labeled *Inference*, *Secondary*, or *Not verified*.
5. Every Mermaid block renders and agrees with the prose.
6. The Summary table, Key Findings, section numbers, and AI disclosure agree with the body.
7. The `/handoff` completion contract passes, including its final diegetic pass.

In Extend mode, also:

- update the Summary table and Key Findings for the new material;
- renumber sections and fix cross-references;
- append the new prompt to the disclosure's prompt list;
- note in the disclosure's `Generated` row which section was added on which date.

Then delete the `temp/` notes.

## Coverage menu

**Core.** Every explainer covers these:

1. **What it is**: the model in one paragraph, then the objects it's made of and how they nest.
2. **Why it exists**: the problem it solves, and what people did before it.
3. **How it works internally**: components, who owns each, and the control and data flow.
4. **How it relates to and differs from each neighbor**, including where they integrate.
5. **Where the authoritative definitions live**: the spec, model, or source that decides behavior, and the team or project that owns it.

**Default.** Include these unless the topic has nothing there, and say so in the plan when you leave one out:

6. **Vocabulary**: the terms the rest of the document uses.
7. **Lifecycle**: one walk through the main unit of work (a request, a connection, a build, a release), start to finish.
8. **Settings and knobs**: each one, what it changes, its default, and why it exists.
9. **How it's used in practice**: typical configuration and deployment, including in the requester's organization when sources show it.
10. **Benefits, costs, and when not to use it.**
11. **Failure modes and pitfalls**: what goes wrong, how it shows up, and how to avoid it.
12. **How it evolved**: major versions, design changes, and the reasons behind them.
13. **Code and repository structure**, for software the reader might open.
14. **Worked example**: one real use, traced end to end.

**Topic-specific.** Add these when the request or the topic calls for them: special environments or edge cases the requester names, migration paths, the code status and timeline of a planned feature, analysis of tickets or proposals, and hypothetical designs. Label a hypothetical design as a proposal that doesn't exist yet.
