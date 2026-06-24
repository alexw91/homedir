---
title: Security-Sensitive Code
inclusion: always
---

# Security-Sensitive Code

Apply these rules to all code. They are non-negotiable in cryptography, protocol implementations, and security-critical paths.

## Rules

- Never skip validation because "the caller already checked" — each function must enforce its own invariants independently
- Never simplify protocol state machine transitions — each state exists because an attack exploited its absence
- Never swallow errors in crypto code — a silent error is a vulnerability
- Fail closed by default. Ambiguous → deny.
- Enforce preconditions early — validate inputs and return errors in the first few lines so the remaining implementation is obviously correct
- Branch on failure, not success — the happy path should read top-to-bottom without nesting
- Minimize branches and cognitive load — treat else clauses with suspicion; prefer exhaustive dispatch over nested conditionals
- Treat all warnings as errors — a warning in security code is an unresolved problem, not informational noise
- Flag any simplification to security code for human review rather than applying silently
- Make invalid states unrepresentable — use the type system to ensure illegal combinations cannot be constructed, not just detected at runtime
- Encode invariants in types, not comments — prefer enums over strings, newtypes over primitives, and sealed hierarchies over open interfaces. A bug the compiler rejects is a bug that never ships.
- Push validation as early as possible in the pipeline: type system > compile time > startup > request time > deep in the call stack. The earlier an invalid state is rejected, the smaller the attack surface.
- Make wrong code look wrong — use naming conventions to surface semantic hazards (byte order, trust boundaries, validation state) so misuse is visible in a single line
- Back every convention with a build-time check. A convention without enforcement is a suggestion that decays.

## Priorities

When weighing trade-offs, this is the priority order:

1. Security
2. Readability
3. Correctness
4. Performance

## Scope Exceptions

The "minimum code" principle from clean-code.md does NOT apply to:

- Defense-in-depth ("can't happen" cases still get an explicit error path)
- Redundant validation at trust boundaries
- Protocol conformance steps that prevent future misuse
- Exhaustive enum/switch handling even when one branch is currently reachable

## Patch Review

- No security check removed, even if unreachable
- Error returns propagate to the caller (no silent swallowing)
- New code paths cannot bypass validation via attacker-controlled input
- Tests must include adversarial cases that attempt to violate the invariants being enforced
- Changes that widen the accept surface require explicit human approval
