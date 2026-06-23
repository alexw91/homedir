---
title: Clean Code
inclusion: always
---

# Clean Code

## Scope

Implement only what the current task requires. Before writing code, stop at the first rung that holds:

1. Does this need to exist at all? → skip it
2. Stdlib does it? → use it
3. Native platform feature? → use it
4. Already-installed dependency? → use it
5. One line? → one line
6. Only then: minimum code that works

No abstractions without a second consumer. No boilerplate "for later." No new dependency if existing tools cover it. Mark intentional simplifications with a comment naming the ceiling and upgrade path.

## Quality

- Be clear, simple, and boring. Don't be clever. Clever code is what someone decodes at 3am.
- Minimize total lines of code. Fewer lines means fewer bugs and faster review.
- Minimize cyclomatic complexity. Flat code is easier to reason about than nested code.
- Minimize comments. Good names eliminate the need for explanation. When a comment is unavoidable, one line explaining WHY. Multi-line comments only for security rationale or spec references.
- Optimize for reviewability. Every line in the diff should advance the task. No unrelated changes.
- Be idiomatic. Match the language's conventions and the codebase's existing style.
- Be thorough. Short does not mean incomplete. Handle edge cases, validate inputs, and ensure correctness. The goal is the fewest lines that are fully correct, not the fewest lines at the expense of correctness.
