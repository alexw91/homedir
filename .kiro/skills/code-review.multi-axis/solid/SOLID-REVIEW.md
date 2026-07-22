# SOLID Principles Review (Sub-skill)

Review the diff for violations of SOLID design principles at module, class, and interface boundaries. Your job is to find structural problems that will make the code harder to extend, test, or maintain — not to enforce orthodoxy on internal function bodies.

## Scope

This axis applies when the diff introduces or modifies:
- Class/struct/trait definitions
- Interface/protocol/abstract type declarations
- Module boundaries (new files, public exports, package APIs)
- Inheritance or composition relationships
- Dependency injection or service wiring

If the diff is purely internal to a single function and touches no type boundaries, this axis SHOULD be skipped by the orchestrator.

## Mindset

Think like a maintainer who will extend this code in 6 months. Ask: "If I need to add a new variant, a new consumer, or a new implementation, where does the existing structure fight me?" SOLID violations are the answer.

Do NOT enforce SOLID for its own sake. A violation matters only if it creates a concrete future problem: forced shotgun surgery, untestable coupling, or impossible-to-add variants.

## Checklist

For each item, evaluate whether the diff introduces or worsens a violation. Only report findings — do not enumerate passing checks.

### S — Single Responsibility

Does the changed class/module have exactly one reason to change?

Signals of violation:
- A class that mixes I/O with domain logic
- A module that handles both serialization AND validation AND business rules
- A change to one feature requiring edits to an unrelated section of the same class
- A constructor/init that accepts unrelated groups of dependencies

### O — Open/Closed

Can the system be extended without modifying the changed code?

Signals of violation:
- A switch/match on a type discriminator that must be updated for every new variant
- A function with `if (type === "A") ... else if (type === "B") ...` chains
- Adding a new feature required modifying the internals of an existing, stable class
- Hard-coded behavior that should be pluggable via composition or strategy pattern

NOT a violation: exhaustive enum matching in security-critical code where completeness is a safety invariant. Defer to the Security axis.

### L — Liskov Substitution

Do subtypes honor the contracts of their base types?

Signals of violation:
- A subclass that throws on a method it inherits (refusing to implement a contract)
- An override that silently narrows preconditions or widens postconditions
- A mock/stub in test code that returns fundamentally different behavior than the real impl (indicates the abstraction boundary is wrong)
- Type casts or instanceof checks immediately after receiving a value through a polymorphic interface

### I — Interface Segregation

Are interfaces focused on what each consumer actually needs?

Signals of violation:
- An interface with methods that some implementations stub out or throw NotImplemented
- A consumer that imports a type but uses only 1-2 of its 10+ methods
- A change that forces an unrelated implementor to add a new method it doesn't need
- "God interfaces" that accumulate methods from unrelated concerns

### D — Dependency Inversion

Do high-level modules depend on abstractions rather than concrete implementations?

Signals of violation:
- A domain/business logic module importing a specific database client, HTTP library, or filesystem API directly
- Constructor that `new`s its own dependencies instead of accepting them
- Test code that requires standing up real infrastructure because the dependency isn't abstractable
- A utility module that imports from a higher-level application module (inverted layer direction)

NOT a violation: Leaf modules (CLI entry points, composition roots, test harnesses) are expected to reference concrete types. The issue is when core logic does.

## Format

One line per finding:

```
[<confidence 1-10>] <principle-letter>: <file>:L<line>. <what's wrong>. → <suggested restructure>.
```

For complex findings:

```
[<confidence>] <principle-letter>: <file>:L<line>. <what's wrong>. → <suggested restructure>.
  Detail: <explanation of the concrete future problem this creates and why the restructure fixes it>
```

Example findings:

```
[9] S: src/OrderService.ts:L12. Class handles HTTP parsing, validation, and database writes. Three reasons to change. → Extract validator and repository.
[8] O: src/handlers/notify.ts:L45. Switch on notification type — adding email requires editing this function. → Strategy pattern or handler registry.
[7] D: src/core/pricing.ts:L3. Domain module imports `DynamoDBClient` directly. Untestable without DDB. → Accept a repository interface.
[6] I: src/storage/IStore.ts:L1. Interface requires `compress()` and `encrypt()` but the S3 impl stubs both. → Split into IStore + ICompressible + IEncryptable.
[8] L: src/auth/OAuth2Provider.ts:L55. Subclass `InternalAuth` throws UnsupportedError on `refreshToken()`. Callers cannot substitute safely. → Remove inheritance; use composition with explicit capabilities.
```

## Rules

- Only flag violations introduced or worsened by the diff. Pre-existing structural problems in untouched code are out of scope.
- Do NOT flag single-implementation abstractions as "good SOLID" when there is no known second consumer. That's YAGNI (Clean axis territory). SOLID findings say "this concrete coupling will hurt when X happens" — name X specifically.
- Do NOT flag exhaustive pattern matching on security-sensitive enums. Those belong to the Security axis's defense-in-depth rule.
- Do NOT flag composition roots, main functions, or DI wiring modules for depending on concrete types. That's their job.
- Be concrete about the future problem. "Violates SRP" is not a finding. "Adding a new payment method requires editing the order validation logic" is.

## Verdict

Follow `OUTPUT-CONTRACT.md` exactly.

**Confidence calibration (SOLID axis):**

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Violation provably forces shotgun surgery for a change the diff's own PR description or issue mentions as upcoming work.
- **9:** Clear violation with a concrete, named future scenario that will require modifying this code in a breaking way.
- **8:** Strong structural smell with a likely (but not certain) second use case visible in the codebase or requirements.
- **6-7:** Plausible future problem, but depends on whether the system actually grows in the direction the reviewer assumes.
- **4-5:** Textbook violation but the code is simple enough that the practical cost is low today.
- **2-3:** Pedantic SOLID observation with no concrete future consequence.
- **1:** Academic exercise. The code works, is testable, and won't need to change. Reporting only for completeness.

Findings scoring ≥ 8 drive `verdict: NEEDS DISCUSSION` (not FIX REQUIRED). SOLID restructuring involves trade-offs and human judgment — the reviewer flags the problem; the author decides whether to restructure now or accept the technical debt.

Exception: An L (Liskov) violation scoring ≥ 9 where callers WILL crash at runtime drives `verdict: FIX REQUIRED`.
