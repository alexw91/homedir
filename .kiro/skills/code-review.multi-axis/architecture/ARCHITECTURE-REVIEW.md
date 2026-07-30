# Architecture Review (Sub-skill)

Review the diff for structural decisions that affect how the codebase grows: where modules live, where seams exist, whether interfaces earn their complexity, and whether the code fights or supports extension. Think like a staff engineer reviewing for long-term maintainability, not SOLID orthodoxy.

## Core Question

**"Are these modules deep — a lot of behavior behind a small interface — or shallow, where callers must understand almost as much as the implementation itself? When the next feature arrives, how many files do you have to touch, and is that because of the problem's inherent complexity or because of how we chose to cut the modules?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P diff @{upstream} --name-only` to identify changed files. Read module boundaries, export surfaces, and dependency direction of touched files. Use `read_code` to inspect type definitions, interface declarations, and the import graph of changed modules. Read callers and siblings when judging placement or seam appropriateness.

**Remote mode:** The diff is provided inline in your prompt. Use the platform-specific file-read recipe for surrounding context — particularly when judging whether a module belongs in its current file/package or whether a seam is justified.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a structural concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `split-brain (new):`, `implicit-ordering (new):`). The same output format, confidence scoring, and verdict rules apply.

### Module Depth and Placement

1. `shallow:` - **Is this module earning its keep?** A module whose interface is nearly as complex as its implementation — callers must know almost everything about the internals to use it correctly. Apply the deletion test: if you deleted this module, would complexity concentrate in one place (bad — the module was shallow wrapper) or would it reappear across N callers (good — the module was absorbing real complexity)? Also applies when a function is extracted purely for testability but the real bugs live in how it's called, not in the logic itself (no locality). The fix is either deepening the module (absorbing more behind the interface) or inlining it into the caller if the abstraction isn't paying for itself. Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `misplaced:` - **Is this code in the right file/module?** Logic that lives in a module where it doesn't belong by cohesion or responsibility. Signals: the function's imports come entirely from a different module, callers are all in a different package, or the name of the containing file doesn't describe what this function does. Also applies when new logic is added to a god-module when a better-named home exists or should be created. The fix is moving the code to where it belongs. Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `missing-module:` - **Should this be its own thing?** A cluster of related logic inlined in a larger function or scattered across multiple files that wants to be a named, reusable unit. The signal: you can articulate a coherent responsibility for the cluster, give it a name that callers would recognize, and the interface would be simpler than the implementation it hides. The fix is extracting to a new module with a clear interface. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Seam Discipline

4. `missing-seam:` - **Is a seam needed here?** A concrete dependency where you can name a second implementation that is either (a) already needed for testing, (b) on the roadmap, or (c) an obvious extension the domain makes inevitable. The dependency is hard-wired — adding the second implementation requires modifying the current function's internals. The fix is introducing a port/interface at the seam. One adapter = hypothetical seam; only flag this when at least two adapters are justified (production + test counts). Verdict ≥ 8: `NEEDS DISCUSSION`.

5. `premature-seam:` - **Is this indirection paying for itself?** An abstraction layer, interface, or port where you cannot name the second consumer or implementation — and the indirection doesn't serve testability (no mock exists in the test suite, no test uses the abstraction boundary). A single-adapter seam is just indirection tax. Also applies when a strategy/plugin pattern exists for one strategy. The fix is inlining until a real second consumer appears. Verdict ≥ 8: `NEEDS DISCUSSION`.

6. `leaking-seam:` - **Does this boundary actually decouple?** A seam/interface that claims to hide implementation details but callers still need to know them: initialization order, internal error codes, performance characteristics, or platform-specific behaviors leak through. The indirection exists but doesn't achieve decoupling. The fix is either making the abstraction genuinely opaque or removing it and letting callers use the underlying thing directly. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Extensibility and Responsibility

7. `single-responsibility:` - **Does this module have one reason to change?** A module that mixes unrelated concerns — I/O with domain logic, serialization with validation, HTTP parsing with business rules. The test: can you name two unrelated external forces that would each independently cause this module to change? If yes, it has multiple responsibilities. A constructor that accepts unrelated groups of dependencies is a symptom. The fix is extracting the unrelated concern into its own unit. Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `extension-hostile:` - **Can the system be extended without modifying this code?** A switch/match on a type discriminator that must be updated for every new variant. Adding a new case requires editing the internals of a stable, existing module. Hard-coded behavior that should be pluggable via composition, strategy pattern, or handler registry. NOT a violation when the switch is an exhaustive match on a security-sensitive enum (defer to Security axis). The fix is a dispatch mechanism that allows extension by addition rather than modification. Verdict ≥ 8: `NEEDS DISCUSSION`.

9. `contract-violation:` - **Do subtypes honor base type contracts?** A subclass/implementation that throws on a method it inherits (refusing to implement a contract). An override that silently narrows preconditions or widens postconditions. A mock that returns fundamentally different behavior than the real impl (indicating the abstraction boundary is wrong). Type casts or instanceof checks immediately after receiving a value through a polymorphic interface. Callers cannot substitute safely. Verdict ≥ 8: `NEEDS DISCUSSION`. Verdict ≥ 9 with runtime crash: `FIX REQUIRED`.

10. `fat-interface:` - **Is this interface focused on what each consumer needs?** An interface with methods that some implementations stub out or throw NotImplemented. A consumer that imports a type but uses only 1-2 of its 10+ methods. A change that forces an unrelated implementor to add a method it doesn't need. The fix is splitting into focused interfaces per consumer role. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Dependency Direction

11. `inverted-dependency:` - **Does high-level logic depend on abstractions or on infrastructure?** Domain/business logic importing a specific database client, HTTP library, or filesystem API directly. A constructor that `new`s its own dependencies instead of accepting them. A utility module importing from a higher-level application module (inverted layer direction). Test code that requires real infrastructure because the dependency isn't abstractable. NOT a violation in composition roots, main functions, CLI entry points, or DI wiring modules — those are expected to reference concrete types. The fix is accepting the dependency as an interface parameter. Verdict ≥ 8: `NEEDS DISCUSSION`.

12. `circular:` - **Are there circular dependencies between modules?** Module A imports from Module B which imports from Module A (directly or transitively through a short chain). Circular dependencies make modules impossible to understand, test, or deploy independently. The fix is breaking the cycle by extracting the shared concern into a third module, or inverting one direction through an interface. Verdict ≥ 8: `FIX REQUIRED`.

13. `layering-violation:` - **Does a lower layer reach up into a higher one?** A module in a lower architectural layer (utility, data access, domain logic) imports from a higher layer (application orchestration, presentation, framework glue). The lower layer should be usable without the higher one — if it imports upward, it can't be. Distinct from `inverted-dependency:` which is about abstraction direction (domain depending on infrastructure). This is about layer direction: infrastructure or data code reaching up into application code for retry logic, error formatting, or request context it shouldn't know about. The fix is passing the needed data down as parameters rather than reaching up to pull it. Verdict ≥ 8: `NEEDS DISCUSSION`.

14. `over-exposed:` - **Does this module export more than callers need?** Internal helpers, intermediate types, or implementation details appear in the public surface of a module/package. Every exported symbol is a commitment — future changes to these internals become breaking changes for consumers. Signals: exports with names like `_internal`, `impl`, or `Helper`; types exported that only one internal function uses; a barrel file that re-exports everything rather than curating a public API. Distinct from `fat-interface:` (too many methods on one interface) — this is about the module's export surface being wider than its conceptual responsibility. The fix is making internals private and exporting only the intended public contract. Verdict ≥ 8: `NEEDS DISCUSSION`.

15. `god-module:` - **Has this module become the gravity well everything connects to?** A single file/class that has absorbed unrelated concerns over time and become the central dependency of the codebase. Signals: 500+ lines, 15+ public methods spanning unrelated concerns, imported by most other modules in the package. Every change to the codebase seems to touch this file. Distinct from `single-responsibility:` in degree and import fan-in — SR flags 2-3 mixed concerns in a normal-sized class; god-module flags the extreme case where the file's centrality makes it a merge-conflict magnet and a comprehension bottleneck. The fix is decomposition along responsibility lines, preserving a thin facade if backward compatibility requires it. Verdict ≥ 8: `NEEDS DISCUSSION`.

16. `unstable-dependency:` - **Does a stable module depend on a volatile one?** A rarely-changing module (core domain, shared library, public API contract) imports from a frequently-changing module (feature code, UI layer, experimental subsystem). Changes to the volatile module force rebuilds, retests, or risk of breakage in the stable one. The stable module's reliability guarantee is only as strong as its least stable dependency. Signals: a `core/` or `lib/` module importing from `features/` or `app/`; a published package depending on an internal tool. The fix is inverting the dependency (have the volatile module depend on the stable one, or introduce an interface at the boundary). Verdict ≥ 8: `NEEDS DISCUSSION`.

17. `mixed-abstraction:` - **Does this function operate at a single level of abstraction?** A function body that interleaves high-level orchestration (business flow, decision logic) with low-level detail (byte manipulation, string parsing, raw I/O calls). The reader must context-switch between "what is the overall flow" and "how does this encoding work" within the same call frame. Signals: a 50-line function where 5 lines describe the workflow and 45 lines implement one step inline. The fix is extracting the low-level detail into a named helper so the orchestrating function reads as a sequence of named steps at one level. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <tag> <file>:L<line>. <what's wrong>. → <suggested restructure>.
```

For complex findings where the structural problem needs explanation:

```
[<confidence>] <tag> <file>:L<line>. <what's wrong>. → <suggested restructure>.
  Detail: <explanation of the concrete future problem this creates, what change will be painful, and why the restructure fixes it>
```

Examples:

```
[9] single-responsibility: src/OrderService.ts:L12. Class handles HTTP parsing, validation, and database writes — three independent reasons to change. → Extract validator and repository; OrderService becomes a thin orchestrator.
[8] extension-hostile: src/handlers/notify.ts:L45. Switch on notification type — adding email requires editing this function. → Handler registry or strategy pattern keyed by notification type.
[7] inverted-dependency: src/core/pricing.ts:L3. Domain module imports DynamoDBClient directly — untestable without DDB running. → Accept a repository interface; inject DDB adapter at the composition root.
[8] shallow: src/utils/retry.ts:L1. Wrapper accepts the same parameters as the underlying setTimeout+fetch and adds only a loop — callers must understand the full retry semantics anyway. → Deepen by absorbing backoff strategy, jitter, and circuit-breaking behind a simpler interface (retryWithDefaults(fn)).
[9] missing-seam: src/auth/session.ts:L20. Session validation hard-wires Redis calls inline. Tests require a running Redis instance. A second impl (in-memory for tests) is already needed. → Extract SessionStore interface; inject Redis adapter.
[6] premature-seam: src/storage/IStore.ts:L1. Interface requires compress() and encrypt() — but only S3Adapter exists and stubs both. No test uses the interface boundary. → Inline until a second adapter materializes.
[8] misplaced: src/api/handlers/user.ts:L88. Password hashing logic inlined in an HTTP handler. All crypto imports come from a different domain. → Move to src/auth/password.ts.
[9] circular: src/models/Order.ts:L5 ↔ src/services/OrderService.ts:L2. Order imports OrderService for validation; OrderService imports Order for types. Neither can be tested independently. → Extract validation rules to src/models/OrderValidation.ts.
[8] contract-violation: src/auth/InternalAuth.ts:L55. Subclass throws UnsupportedError on refreshToken() — callers through the OAuth2Provider interface will crash. → Remove inheritance; use composition with explicit capability interfaces.
[8] layering-violation: src/db/connection-pool.ts:L12. Data-access module imports from src/api/middleware/auth.ts to get the current user for audit logging. Lower layer reaches into application layer. → Pass the user ID down as a parameter from the application layer.
[7] over-exposed: src/core/index.ts:L1. Barrel file re-exports 40 symbols including internal helpers (buildCacheKey, normalizeInput, INTERNAL_TIMEOUT). Consumers depend on internals that should be free to change. → Export only the 8 public-contract types/functions; make helpers module-private.
[8] god-module: src/app/AppContext.ts:L1. 900-line class imported by 34 of 40 modules. Mixes config loading, service registry, logging setup, and request routing. Every feature change touches this file. → Decompose into ConfigLoader, ServiceRegistry, and Router; keep AppContext as a thin composition root.
[7] unstable-dependency: src/lib/validation.ts:L2. Shared validation library imports from src/features/billing/types.ts for one type alias. Billing changes trigger validation rebuilds across 12 packages. → Copy or extract the type to a shared-types module.
[8] mixed-abstraction: src/pipeline/process.ts:L15. Orchestration function interleaves "for each record, validate then enrich then persist" with 30 lines of inline CSV column-index arithmetic. → Extract CSV parsing to a named helper; let process() read as a sequence of named steps.
```

## Confidence Calibration (Architecture axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Structural problem provably forces shotgun surgery for a change the diff's own PR description or linked issue mentions as upcoming work.
- **9:** Clear structural problem with a concrete, named future scenario that will require painful multi-file edits or will silently invalidate an assumption at runtime.
- **8:** Strong structural smell with a likely (but not certain) second use case visible in the codebase, requirements, or domain.
- **6-7:** Plausible future problem, but depends on whether the system actually grows in the direction the reviewer assumes. Worth raising for discussion.
- **4-5:** Textbook concern but the code is simple enough that the practical cost is low today.
- **2-3:** Pedantic observation with no concrete future consequence.
- **1:** Academic exercise. The code works, is testable, and won't need to change.

## Rules

- Only flag structural problems introduced or worsened by the diff. Pre-existing architecture issues in untouched code are out of scope.
- Every finding MUST name a concrete future problem. "Violates SRP" is not a finding. "Adding a new payment method requires editing the order validation logic because HTTP parsing, validation, and persistence are interleaved in one class" is.
- Apply the deletion test before flagging `shallow:`. Imagine deleting the module. If complexity reappears across N callers, the module is earning its keep — don't flag it.
- Apply the two-adapter test before flagging `missing-seam:`. If you can't name the second implementation (production + test counts), the coupling is appropriate.
- Do NOT flag composition roots, main functions, or DI wiring for depending on concrete types. That's their job.
- Do NOT flag exhaustive pattern matching on security-sensitive enums as `extension-hostile:`. Those belong to the Security axis's defense-in-depth rule.
- Do NOT flag single-implementation abstractions without a known second consumer as `premature-seam:` when the single implementation is a test mock — a production + test pair is a legitimate two-adapter seam.
- Read beyond the diff. Architecture findings require understanding callers, callees, import graphs, and module boundaries. Use `--name-only` to triage, then selectively read surrounding context.

## Boundaries

Overlap between axes is acceptable and expected. Multiple axes reporting the same issue from different lenses is a stronger signal, not a problem. The orchestrator does not deduplicate across axes.

- **vs Quality:** A structural problem might also be flagged by Quality as `tight-coupling:` or `disproportionate:`. Architecture frames it as "where should the boundary live?"; Quality frames it as "is this the right engineering approach?" Both are valid.
- **vs Clean:** An unused abstraction might be flagged by Clean as `yagni:` (delete it) and by Architecture as `premature-seam:` (the indirection isn't earning its keep). Both reinforce the same conclusion from different angles.
- **vs Security:** Exhaustive enum matching in security-critical code is defense-in-depth from Security's perspective. If it also looks like `extension-hostile:` from Architecture's perspective, both can flag it — Architecture should note the security rationale if visible.
- **vs Style:** File naming conventions belong to Style. Whether code is in the *right* file belongs here. Both can flag a misnamed file that's also in the wrong location.
- **vs Performance:** A missing batch API might be flagged by both Architecture (structural seam needed) and Performance (N+1 calls). Both perspectives are valuable.
- **vs Ready-for-Human-Review:** Dangling references to deleted modules belong to Ready-for-Human-Review. Modules that *should* be extracted but haven't been yet (`missing-module:`) belong here. A function referencing a removed module could be flagged by both.
