---
title: Clean Code
inclusion: always
---

# Clean Code

## Diff Budget

A human reads every line you write, and their attention is the scarce resource — not your time, not the line count. Review cost scales faster than diff size: a ten-line CR merges in minutes, a hundred-line CR merges tomorrow, a thousand-line CR gets rubber-stamped or stuck for weeks. A diff too large to review ships unreviewed.

So the first question on a change is not "does this work" but "what is the smallest diff that works." Every line spends budget, and every line must earn it: you can name the requirement it serves, or you revert it. When you finish, re-read the diff as the reviewer will — top to bottom, with no memory of how it got that way.

Three checks on the finished diff:

- Can you justify each changed line with a direct link to the task? If not, revert it.
- Did you touch code you weren't asked to touch? Leave it. Pre-existing issues are not your problem unless explicitly requested.
- Did you reformat, reorder imports, rename unrelated variables, or "improve" neighboring code? Revert it. Reformatting hides real changes in review.

The rest of this file is how you stay inside the budget.

## Scope

Implement only what the current task requires. Each rung you descend spends more budget, so stop at the first rung that holds:

1. Does this need to exist at all? → skip it
2. Stdlib does it? → use it
3. Native platform feature? → use it
4. Already in this codebase, or an installed dependency? → use it
5. One line? → one line
6. Only then: minimum code that works

No abstractions without a second consumer you can name (a test double counts). Apply the deletion test before adding a module: if deleting it would make complexity vanish, it was a pass-through; if the complexity would reappear across its callers, it was earning its keep. No boilerplate "for later." No new dependency if existing tools cover it. Before creating a file, check whether convention already maps this change to an existing one — a change to `src/foo.c` belongs in `tests/foo_test.c`, and `utils.ts` already owns what `utils2.ts` would.

Don't solve problems you don't have yet. Code for today's requirements. If a future need arises, refactor then — it's cheaper than maintaining speculative abstractions now.

## Quality

- Be clear, simple, and boring. Don't be clever. Clever code is what someone decodes at 3am.
- Minimize cyclomatic complexity. Flat code is easier to reason about than nested code.
- Accept dependencies, return results. A function that constructs its own collaborators or mutates state in place can only be tested with ceremony. One that takes what it needs and hands back what it computed tests with a call.
- Ship the product, not the process. Remove the scaffolding before handing off: comments about approaches not taken, development narration ("cleaner than the previous version"), leftover debug output and TODOs, absolute paths from your machine, names inherited from an earlier attempt.
- Be idiomatic. Match the language's conventions and the codebase's existing style.
- Use the domain's established word. When a concept has a canonical name — TLS "cipher suites", pipeline "stages" — a coherent synonym still compounds into tests, docs, and conversations.
- Preserve identifier fidelity. When a key, path, ARN, or URI exists in canonical form, use that form in logs, error messages, test names, and diagnostics. The test: a reader copies the value out of the output, pastes it into a codebase search, and lands on exactly one definition.
- Be thorough. Short does not mean incomplete. Handle edge cases, validate inputs, and ensure correctness. The goal is the fewest lines that are fully correct, not the fewest lines at the expense of correctness.

## Comments

Comments explain **why**. One line inline, two at most. Links — URLs, ticket IDs, spec sections — don't count against that budget; include them whenever they point at the originating requirement.

Restating the signature earns nothing. `export function` already says public; the type already says the type. If a reader needs a comment to understand *what* a thing is, fix the name. The same comment repeated at three or more sites is the same smell at scale: either it restates what the code already says, or the meaning it carries belongs in one place — the shared function, enum, or header those sites already reference — with the sites pointing there instead.

Comment the code in front of you. A claim about another file is **hearsay**: it goes stale the moment someone edits that file, and then it lies silently. Prefer leaving it out; when the coupling genuinely matters, one line plus a link. A claim about another **repo** needs explicit authorization — stop and ask first. You cannot see that repo's tests, so you cannot know when your claim stops being true.

Doc comments (`/** */`, docstrings, `///`) may run multiple lines. They state the contract a caller needs: behavior, parameters, returns, errors, constraints. Rationale aimed at future maintainers goes in the commit message or the linked ticket, not the doc block.

A multi-line inline comment is a smell. The exception is a genuinely critical requirement at that line — most often security rationale or a spec reference.

When behavior changes, the comments and tests describing it change in the same diff.

## Related

See also: `think-plan-act.md` (execution loop), `security-sensitive-code.md` (scope exceptions to minimalism), `prefer-reusable-tooling.md` (tooling you write to do the work, as distinct from code you ship)
