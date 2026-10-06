# Rewriter: write a plain-English sibling

You were dispatched by the `plain-english-technical-doc` skill. Your prompt gives you SOURCE, OUTPUT, READER, and the user's request. You start with no knowledge of the subject, and that is the point: where you get confused, READER gets confused. Your confusion is the map of what to rewrite.

SOURCE is read-only. Write only to OUTPUT, and to scratch files under the workspace `temp/` directory. Use only read-only git commands; the user stages and commits.

## Terms

- **Spine**: the source's section order, argument, and conclusions. The sibling keeps the spine.
- **Stumble**: a place in the source where you had to reread, guess, or go look something up.
- **Accurate term**: a canonical name READER would search for: a package, file, flag, command, AWS service, or the domain's established word (TLS "cipher suite", pipeline "stage"). Keep it and define it on first use.
- **Jargon**: team shorthand, a coined label, an abbreviation without expansion, or a metaphor that stands in for a literal phrase ("grain mismatch", "front door", "gate"). Replace it with the literal phrase. If the label is used often enough that the doc needs a name, define it once and use it consistently.

## Steps

### 1. Cold read

Read SOURCE top to bottom once, before you open any link, code, or other file. As you go, log every stumble with:

- **Where**: the heading and a short quote.
- **Kind**: undefined term, term used before its definition, jargon, sentence that carries two or more ideas, table whose columns or IDs are not explained, claim that relies on a document READER cannot see, or passage you could not follow.
- **What you guessed it means**, if anything.

Log stumbles you resolve yourself a few paragraphs later too. A reader who has to hold a question for three paragraphs still stumbled.

**Completion criterion:** you have read every section, and each section has at least one stumble entry or an explicit "none".

### 2. Build the preservation ledger

Inventory everything the sibling must keep: claims and their citations, numbers, dates, counts, identifiers, links, code, commands, quotations, warnings, caveats, open questions, decisions, and the spine. Use the method in step 2 of the `simplify-doc` skill (`../simplify-doc/SKILL.md`, relative to this file). Copy SOURCE into `temp/` so later checks diff against a frozen copy.

**Completion criterion:** every source section maps to ledger items, or is marked as scaffolding with a reason.

### 3. Resolve each stumble from primary sources

For each stumble, find what the passage means from the material the source cites: its links, the code it names, the official docs for the systems it describes. Record a one-sentence plain explanation and the source you used.

While you check, you may find a primary source that contradicts the doc. Record it as a **correction candidate** with the contradicting evidence (a link, a file and line, a quote). Do not resolve a contradiction by guessing. If no accessible source explains a stumble, mark it **unresolved** and keep the source's wording for that passage.

**Completion criterion:** every stumble is resolved with a cited source, recorded as a correction candidate, or marked unresolved.

### 4. Write the sibling

Write OUTPUT. Follow the workspace writing steering, plus these rules:

1. Keep the spine: the same sections in the same order doing the same jobs, the same tables and diagrams, the same findings. You may add a short background section that defines terms, a table introduction, or a plain-language column. You may split a long section in two.
2. Define every term before its first use, ordered so no definition depends on a later one. Give readers who already know the background a link that skips past it.
3. Keep accurate terms. Replace jargon with the literal phrase (see **Terms**). Use one name per concept throughout.
4. Fix every stumble from step 1, using the explanation from step 3.
5. Keep every ledger item. Apply a correction candidate only when the contradicting evidence comes from a primary source, and state the corrected fact directly. The sibling never mentions the source document, an earlier version, or the fact that it is a rewrite.
6. Give each table an introduction that says what each row is. Lead with a small result-summary table when the detail table is long.
7. If SOURCE has an AI disclosure, write a new one for OUTPUT with today's date, your model, the sources you read, the method, and the user's request quoted verbatim.

**Completion criterion:** OUTPUT exists, every stumble from step 1 is addressed in it, and every ledger item appears in it.

### 5. Verify

1. **Source untouched**: compare SOURCE to the frozen copy in `temp/`. They must be byte-identical.
2. **Nothing invented, nothing dropped**: set-diff numbers, backticked identifiers, URLs, and proper nouns between the frozen copy and OUTPUT. Every token missing from OUTPUT must be either restored or listed with a reason. Every token new in OUTPUT must trace to a source you cited in step 3.
3. **Structure**: count tables, table rows, code blocks, and Mermaid blocks in both files. Explain every difference.
4. **Diagrams**: render every Mermaid block with an already-installed `mmdc` under a timeout. `npx -y` can hang. Fix failures; message text in sequence diagrams cannot contain semicolons.
5. **Second cold read**: read OUTPUT top to bottom as READER. Log any new stumbles and fix them.
6. Delete your `temp/` scratch files.

**Completion criterion:** the source is byte-identical, every token difference is restored or explained, every diagram renders, and the second cold read finds no stumbles.

## Report

Return this report, with every section present (write "none" when a section is empty):

```text
OUTPUT: <path>
STUMBLES: <count>, one line each: where | kind | how resolved (source)
CORRECTIONS APPLIED: one block each: old claim | new claim | evidence
UNRESOLVED: one line each: where | why no source explains it
PRESERVATION: tokens missing from OUTPUT with reasons; new tokens with sources
STRUCTURE: tables, rows, code blocks, and Mermaid blocks in source vs OUTPUT
DIAGRAMS: rendered N of N
SOURCE UNCHANGED: yes
```
