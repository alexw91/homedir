---
title: Think Plan Act
inclusion: always
---

# Think Plan Act

Execute in three phases: understand the problem, plan the approach, then implement. Skipping phases produces code that gets rewritten.

## 1. Think: Understand Before Touching Code

Read the files you intend to modify. Not skim. Read. Then:

- Identify existing patterns. How is this type of thing already done in this project? Follow that pattern.
- Check imports and dependencies. They define what this project uses. Don't introduce alternatives.
- Read the tests. They define expected behavior more precisely than prose descriptions.
- If no pattern exists, say so and ask rather than inventing one.

The failure mode: generating "correct" code that is alien to the codebase. It works, but it looks like a different project. Inconsistency is a maintenance cost that compounds.

## 2. Plan: State Intent Before Writing

Before writing code, make the following explicit:

- **Success criteria.** Transform vague asks into verifiable outcomes. "Add validation" → "reject missing or malformed email, return 400 with a descriptive message, cover both cases in tests."
- **Assumptions.** If the task is ambiguous, name the assumption and confirm it. A wrong assumption costs an hour. A clarifying question costs ten seconds.
- **Tradeoffs.** If the implementation choice has consequences (performance, complexity, new dependency), name them. The human may want a different tradeoff.
- **Steps.** For multi-step work, state the plan before executing. This catches wrong approaches before they're built.

Do not present five options. Two or three, with a recommendation. The human refines a proposal faster than they generate one from scratch.

## 3. Act: Surgical, Verifiable Changes

### Minimal Diffs

Every changed line must connect directly to what was asked. The tests for a clean diff:

- Can you justify each changed line with a direct link to the task? If not, revert it.
- Did you touch code you weren't asked to touch? Leave it. Pre-existing issues are not your problem unless explicitly requested.
- Did you reformat, reorder imports, rename unrelated variables, or "improve" neighboring code? Revert it. Reformatting hides real changes in review.

### Match Existing Style

Consistency within a file beats personal preference. Match quotes, casing, indentation, semicolon usage, and patterns already present. See `clean-code.md` for the broader code quality standard.

### Clean Up Only Your Own Mess

If your change makes an import, variable, or function unused, remove it. If it was already unused before your change, leave it.

## 4. Verify: Prove It Works

The difference between code that works and code you think works is execution.

- **Bug fixes:** Write a failing test first. Fix the bug. Watch the test pass. This proves you fixed the cause, not the symptom.
- **New behavior:** Run existing tests before and after your change. If something broke, your change caused it.
- **Pre-existing failures:** If tests were already failing, say so explicitly. Don't let your change get blamed.
- **Untestable code:** If you can't write a test, say why. That's a signal about the architecture, not permission to skip verification.

## 5. Debug: Investigate, Don't Guess

When something fails:

1. Read the full error message and stack trace. The specific message matters more than the error type.
2. Reproduce first. If you can't trigger the failure, you can't confirm the fix. When the failure *is* reproducible, use that reproduction as a bisection tool: change one variable at a time (binary version, config, test harness, environment) and observe which change makes it pass. One controlled experiment outweighs ten code-reading sessions.
3. Change one thing at a time. Multiple simultaneous changes make root cause unknowable.
4. Prefer empirical falsification over code-path reasoning. If there's a test you can run, a binary you can swap, or an environment variable you can toggle that would distinguish two hypotheses in minutes, do that before spending an hour reading source code. Code reading generates plausible theories. Experiments eliminate wrong ones.
5. "Code didn't change" is not the same as "behavior didn't change." The same function behaves differently depending on what processes are running, what ports are occupied, what files exist on disk, and what prior invocations left behind. When debugging a failure in a multi-step sequence, ask: "What is the runtime environment at this point, and how does it differ from the environment when this same code succeeds?"
6. Understand before patching. A null check without understanding why the value is null hides the bug behind a band-aid.
7. If stuck after two attempts, stop and say what you've tried, what you're seeing, and what you suspect. Do not silently iterate.
8. When stuck, ask: "What is the cheapest experiment that would prove or disprove my current theory?" If you can't name one, your theory may be unfalsifiable — which means it's not useful.

## 6. Failure Modes to Catch

Stop and reconsider if you notice yourself doing any of these:

| Pattern | Signal | Corrective |
|---------|--------|------------|
| Kitchen Sink | Changing files unrelated to the task | Revert. Do the one thing asked. |
| Invisible Decision | Making an architectural choice without flagging it | Surface it. Hard-to-reverse choices need human buy-in. |
| Knowledge Hallucination | Using an API, parameter, or method you haven't verified exists | Check the source or docs. If uncertain, say so. |
| Runaway Refactor | A fix cascading across 5+ files | Stop. Explain the cascade. Get buy-in before continuing. |
| Optimistic Path | Happy path works, error paths crash | Think: what happens when the network fails, the file is missing, the input is empty? |
| Complexity Attraction | Investigating the most complex subsystem while ignoring simpler explanations (a background process, a stale file, a missing cleanup step) | Ask: "What is the simplest category of bug that could produce this symptom?" Check that first. |
| Confirmation Bias Escalation | 5+ tool calls deepening a single theory without an empirical check that could disprove it | Stop. State the theory as a falsifiable hypothesis. Name the experiment that would disprove it. If no such experiment exists, the theory is not actionable — try a different angle. |

## Cross-References

- Simplicity, dependency ladder, code quality → `clean-code.md`
- Human decision authority, asking vs. assuming → `human-in-the-loop.md`
- Security-specific verification and error handling → `security-sensitive-code.md`
- Communication style for explanations → `writing-tone-and-style.md`
