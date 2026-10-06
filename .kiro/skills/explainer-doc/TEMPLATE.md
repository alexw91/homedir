# Explainer skeleton

This skeleton extends the `/handoff` `reference` structure (Summary, Content, Key Findings, Sources). Replace each `<prompt>` as you write.

**File name.** In a directory of explainers, name the file `<Topic> Explained.md`. Otherwise use the `/handoff` storage convention with the `reference` type.

````markdown
# <Topic> Explained: <the main coverage areas, in section order>

## AI Disclosure - How this document was generated

| Field | Value |
|---|---|
| Author | <agent, directed by requester> |
| Model | <model name, exactly as the session reports it> |
| Generated | <ISO date; in Extend mode, add "<section> added <date>"> |
| Primary input | The request quoted below |
| Source code read | <repositories or packages, each with the commit, tag, or branch and the read date> |
| Documents read | <specs, owner docs, and other documents, grouped by owner> |
| Live evidence | <reproductions, commands run, and data queried, with dates; or "None. No systems were called or changed."> |
| Not verified | <one line, or "See Not verified"> |

**Method.** This document is entirely AI generated. <Name the research passes and what each covered. Name the load-bearing claims re-read at source, the reproductions and their tool versions, and any fact-check pass. State the labels used: *Inference*, *Secondary*, *Illustrative*. State that every Mermaid block was render-checked.>

**Original Prompt.** <use "Prompts" for several, in order>

```text
<the request, verbatim, typos included; leave out secrets and personal data>
```

## Summary

<One paragraph defining the topic. Then one sentence on the starting model: confirm it, sharpen it, or correct it.>

<Two or three paragraphs, or a numbered list of the four to eight facts that carry most of the understanding.>

| Question | Short answer | Section |
|---|---|---|
| <one row per core item, default item, and requester question> | <one sentence> | <n> |

## Content

### How to read this document

<Which sections build the model, which are internals, which are practical, and which are reference. What the reader is assumed to know, with links to define it. Where a reader who knows the basics can skip ahead.>

### 1. <What it is: the model in one paragraph>

<numbered sections, one per planned coverage item>

## Key Findings

<Numbered conclusions. An expert skimming only this section gets back up to speed.>

## Not verified

<Each claim you could not confirm, and what would confirm it.>

## Sources

<Grouped by owner or type, with pinned links. Every inline citation appears here.>
````

If the destination requires a classification banner, put it on the line directly under the H1, above the disclosure.
