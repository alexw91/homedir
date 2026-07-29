# SOLID Principles Review (Sub-skill)

Review the diff for violations of SOLID design principles at module, class, and interface boundaries. Your job is to find structural problems that will make the code harder to extend, test, or maintain — not to enforce orthodoxy on internal function bodies.

## Core Question

**"If I need to add a new variant, a new consumer, or a new implementation in 6 months, where does the existing structure fight me?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P show <sha>` to inspect committed changes. Read class definitions, interface declarations, and module boundaries touched by the diff.

**Remote mode:** The diff is provided inline in your prompt. Use the platform-specific file-read recipe for surrounding context if needed.

## Scope

This axis applies when the diff introduces or modifies:
- Class/struct/trait definitions
- Interface/protocol/abstract type declarations
- Module boundaries (new files, public exports, package APIs)
- Inheritance or composition relationships
- Dependency injection or service wiring

If the diff is purely internal to a single function and touches no type boundaries, this axis SHOULD be skipped by the orchestrator.

## Findings Catalog

1. `S:` - **Single Responsibility — does this class have one reason to change?** A class that mixes I/O with domain logic. A module that handles serialization AND validation AND business rules. A change to one feature requiring edits to an unrelated section of the same class. A constructor that accepts unrelated groups of dependencies. Each of these signals multiple responsibilities. The fix is extracting the unrelated concern into its own unit. Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `O:` - **Open/Closed — can the system be extended without modifying this code?** A switch/match on a type discriminator that must be updated for every new variant. A function with `if (type === "A") ... else if (type === "B") ...` chains. Adding a new feature required modifying the internals of an existing, stable class. Hard-coded behavior that should be pluggable via composition or strategy pattern. NOT a violation: exhaustive enum matching in security-critical code where completeness is a safety invariant — defer to Security axis. Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `L:` - **Liskov Substitution — do subtypes honor base type contracts?** A subclass that throws on a method it inherits (refusing to implement a contract). An override that silently narrows preconditions or widens postconditions. A mock/stub in test code that returns fundamentally different behavior than the real impl (indicating the abstraction boundary is wrong). Type casts or instanceof checks immediately after receiving a value through a polymorphic interface. Callers cannot substitute safely. Exception: an L violation scoring ≥ 9 where callers WILL crash at runtime drives `FIX REQUIRED`. Verdict ≥ 8: `NEEDS DISCUSSION`. Verdict ≥ 9 with runtime crash: `FIX REQUIRED`.

4. `I:` - **Interface Segregation — are interfaces focused on what each consumer needs?** An interface with methods that some implementations stub out or throw NotImplemented. A consumer that imports a type but uses only 1-2 of its 10+ methods. A change that forces an unrelated implementor to add a new method it doesn't need. "God interfaces" that accumulate methods from unrelated concerns. The fix is splitting into focused interfaces per consumer. Verdict ≥ 8: `NEEDS DISCUSSION`.

5. `D:` - **Dependency Inversion — does high-level logic depend on abstractions?** A domain/business logic module importing a specific database client, HTTP library, or filesystem API directly. Constructor that `new`s its own dependencies instead of accepting them. Test code that requires standing up real infrastructure because the dependency isn't abstractable. A utility module that imports from a higher-level application module (inverted layer direction). NOT a violation: leaf modules (CLI entry points, composition roots, test harnesses) are expected to reference concrete types — the issue is when core logic does. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <principle-letter>: <file>:L<line>. <what's wrong>. → <suggested restructure>.
```

For complex findings:

```
[<confidence>] <principle-letter>: <file>:L<line>. <what's wrong>. → <suggested restructure>.
  Detail: <explanation of the concrete future problem this creates and why the restructure fixes it>
```

Examples:

```
[9] S: src/OrderService.ts:L12. Class handles HTTP parsing, validation, and database writes. Three reasons to change. → Extract validator and repository.
[8] O: src/handlers/notify.ts:L45. Switch on notification type — adding email requires editing this function. → Strategy pattern or handler registry.
[7] D: src/core/pricing.ts:L3. Domain module imports `DynamoDBClient` directly. Untestable without DDB. → Accept a repository interface.
[6] I: src/storage/IStore.ts:L1. Interface requires `compress()` and `encrypt()` but the S3 impl stubs both. → Split into IStore + ICompressible + IEncryptable.
[8] L: src/auth/OAuth2Provider.ts:L55. Subclass `InternalAuth` throws UnsupportedError on `refreshToken()`. Callers cannot substitute safely. → Remove inheritance; use composition with explicit capabilities.
```

## Confidence Calibration (SOLID axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Violation provably forces shotgun surgery for a change the diff's own PR description or issue mentions as upcoming work.
- **9:** Clear violation with a concrete, named future scenario that will require modifying this code in a breaking way.
- **8:** Strong structural smell with a likely (but not certain) second use case visible in the codebase or requirements.
- **6-7:** Plausible future problem, but depends on whether the system actually grows in the direction the reviewer assumes.
- **4-5:** Textbook violation but the code is simple enough that the practical cost is low today.
- **2-3:** Pedantic SOLID observation with no concrete future consequence.
- **1:** Academic exercise. The code works, is testable, and won't need to change. Reporting only for completeness.

## Rules

- Only flag violations introduced or worsened by the diff. Pre-existing structural problems in untouched code are out of scope.
- Do NOT flag single-implementation abstractions as "good SOLID" when there is no known second consumer. That's YAGNI (Clean axis territory). SOLID findings say "this concrete coupling will hurt when X happens" — name X specifically.
- Do NOT flag exhaustive pattern matching on security-sensitive enums. Those belong to the Security axis's defense-in-depth rule.
- Do NOT flag composition roots, main functions, or DI wiring modules for depending on concrete types. That's their job.
- Be concrete about the future problem. "Violates SRP" is not a finding. "Adding a new payment method requires editing the order validation logic" is.

## Boundaries

- **vs Clean:** Single-implementation abstractions with no known second consumer belong to Clean (`yagni:`), not here. SOLID finds structural problems that will hurt when a *named* extension happens.
- **vs Quality:** Quality's `tight-coupling:` and `disproportionate:` overlap with SOLID's D and S principles. If the finding is about a specific interface/type boundary → SOLID. If it's about general approach proportionality → Quality.
- **vs Security:** Exhaustive enum matching in security-critical code is defense-in-depth, not an O-principle violation. Defer to Security.
