---
title: Writing Tone and Style
inclusion: always
---

# Writing Tone and Style

Write for an audience that spans non-technical executive leadership to extremely technical distinguished engineers. Both should find the document clear on first read — executives without needing implementation details, engineers without feeling talked down to.

## Principles

1. Conclusions first, then evidence. Lead with the answer; support it below.
2. Lead with what you need from the reader. A decision, an approval, or a specific action. Context follows.
3. Write about the reader's problem, not your process. The reader needs the state of the system, the decision they face, the fact they came for — not a narration of what you did to find it. "Searched the logs, then checked the config, then found..." is your path; delete it and state what you found. Report process only when it is the evidence: a reproduction that proves a fix, a method the reader must trust or repeat.
4. Every paragraph must advance the reader toward that outcome. If a section doesn't serve the ask, cut it.
5. Be specific. Name the component, quote the metric, cite the line. "Improved performance" is not a claim — "reduced `parseHeader` p50 from 120µs to 90µs" is.
6. Distinguish observation from inference. "The p99 spiked at 14:32" is a fact. "The deploy caused it" is a hypothesis. Write so the reader can tell which is which.
7. One idea per sentence. One topic per paragraph. If a sentence makes two claims, split it.
8. Use the active voice when the actor is known. "The deploy broke pagination" not "pagination was broken."
9. Never use a long word where a short one will do. "Use" not "utilize." "Start" not "initialize" (unless the programmatic operation).
10. If you can cut a word, phrase, or sentence without harming meaning, clarity, or natural phrasing, then cut it.
11. Don't reach for ready-made phrases. "Raises the bar," "single point of failure," "ensures we are well-positioned" — these fill space without conveying thought. Say what specifically changed, what specifically fails, what specifically you'll do.
12. Write for the spoken voice. Read a paragraph aloud; if you would not say it that way to a colleague, rewrite it. This catches mannered prose: a metaphor standing in for an available literal phrase. "A dial worth turning" for "a parameter worth varying." "This point earns its keep" for "this point still matters." The metaphor drags in connotations you did not choose. Keep a metaphor only when it names something with no short literal equivalent — a *tracer bullet*, a *diff budget*. If you can name the literal phrase, use it.
13. Prefer everyday English over jargon — unless the technical term is more precise for the audience. "Lock" not "mutex" in an executive summary. "Mutex" not "lock" in a threading design doc.
14. State the thing directly. Use "not X, Y" only when the reader probably believes X. Correcting a real assumption is clarity. Constructing a fake one to refute is filler. The same applies to options: raise an alternative only if the reader would genuinely weigh it. An option introduced so it can be dismissed is drafting residue.
15. Two examples are enough. One illustrates. Two proves a pattern. Three is the second one in different clothes.
16. Don't announce what you're about to say. Just say it.
17. State the caveat; don't announce it. "It's worth noting," "to be precise," "the honest answer is," "one caveat before we start" — cut the preamble and keep what follows. If nothing follows, the preamble was the whole sentence. The same move hides behind *specific* and *precise*: "they differ in one specific way" promises the detail and withholds it. Name the difference.
18. Watch for consecutive paragraphs that both end on a punchy closer. One lands. Two in a row sounds rehearsed.
19. Vary the length and shape of neighboring sentences. A string of identically-structured short sentences is as monotonous as a run-on.
20. Be kind. Earn trust. Critique actions, not character. "This PR lacks error handling" invites a fix. "This engineer is sloppy" damages trust.
21. No more than three nouns in a row. Break long chains with prepositions. "TLS policy signature algorithm negotiation failure rate" → "the failure rate for signature algorithm negotiation in TLS policies."
22. Use the same word for the same thing throughout a document. If you call it "listener" in one paragraph, don't call it "endpoint" in the next unless you mean something different.
23. If a pronoun could refer to two nouns, use the noun again. "The policy updates the listener. It then restarts" — which restarts? Name it.
24. Write as though this is the only version. A document must not narrate its own development — no references to earlier drafts, no corrections of claims the reader never saw, no accounts of abandoned approaches. History of the *work* can be evidence: a failed run that proves the tooling fails safe belongs in a methodology section. History of the *document* never is.
25. Break any of these rules sooner than write like a machine.

## Structure

- Start with a one-sentence summary or conclusion that stands alone.
- Use headings to let readers skip to what they care about.
- Put technical depth in clearly labeled sections so non-technical readers can skip them and technical readers can find them.
- Number multi-step sequences. Readers lose their place in narrative procedures. A numbered list lets them resume after an interruption.
- Order sections so the argument moves. Swap two non-adjacent sections; if nothing breaks, the document is a stack of interchangeable blocks, not a line of reasoning.
- Let section length follow content. Uniform section depth, and a recap sentence closing every section, are signs the shape was filled in rather than written.

## Formatting

- Never hard-wrap lines in markdown files. Let markdown renderers wrap text to fit.

## What to Avoid

- Restating the same point in different words for emphasis. Test each paragraph against the one before: if it adds nothing but volume, merge them.
- Throat-clearing introductions and pre-announcements ("As we all know...", "It's worth noting that...", "In this section we will...")
- Acronyms without expansion on first use
- Weasel words (significant, probably, should, often). Replace with data or a statement of intent.
- Stock figures of speech: "move the needle," "at the end of the day," "deep dive," "circle back," "low-hanging fruit."
- No marketing language. No "leveraging synergies" or "best-in-class solutions."
- Sentences over ~25 words. Not a wall — a warning. If one exceeds it, re-read. It probably needs splitting.
- Long unranked lists. If the reader can't hold the whole list in their head, rank it or split it into tiers. Prioritization is information.

## Explanation Depth

Match depth to demonstrated knowledge. If the human used the term correctly, they don't need a definition. Over-explaining signals that you aren't listening.

## Evidence and Claims

Every factual claim must be backed by a citable reference (link, document name, data source). Do not state things as fact without evidence. If a claim cannot be substantiated from available sources, ask the human for a reference rather than asserting it unsupported.

## Related

See also: `think-plan-act.md` (planning communication), `human-in-the-loop.md` (decision authority)
