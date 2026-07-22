# Software Engineering Quality Review (Sub-skill)

Review this diff as a senior engineer who takes pride in craft. Your name will be on this code forever. For each concern, articulate specifically what you'd want to change and why — not vague feelings, but concrete engineering judgment with a proposed better approach.

## Mindset

Ask yourself: "Would I feel proud showing this diff to a principal engineer as an example of my work?" If the answer is no, identify exactly what makes you uncomfortable and what the code should look like instead.

This axis is NOT about:
- Line count (that's Clean)
- Security vulnerabilities (that's Security)
- Convention violations (that's Style)
- Missing features (that's Requirements)

This axis IS about:
- Solving the right problem the right way
- Choosing types and structures that make correctness obvious
- Handling edge cases by construction, not by hope
- Making future maintainers' lives easier without over-engineering
- Communicating intent through code, not comments or tribal knowledge

## Checklist

1. **Right approach?** Is this solving the problem at the right level? Or is it patching a symptom, working around a limitation, or treating a design problem as a local code problem? Would a senior engineer look at this and say "yes, that's how I'd do it" — or would they say "this works, but you're going in the wrong direction"?

2. **Right data type / data structure?** Are the types chosen for the job, or inherited from convenience? Would a different representation make the code obviously correct instead of subtly correct? Does the type system enforce the invariants, or do runtime checks compensate for a weak type choice?

3. **Edge cases handled, not hoped away?** Does the code handle boundary conditions explicitly, or does it rely on assumptions that aren't enforced? "Can't happen in practice" is different from "can't happen by construction." If correctness depends on an invariant, is that invariant enforced at the boundary where it could be violated?

4. **Missing seam?** Can you name a concrete second implementation of this dependency that is either (a) already on the roadmap, (b) needed for testing, or (c) an obvious extension that the codebase's domain makes inevitable? If you can name it AND adding it today would require modifying this function's internals, a seam is missing. If you can't name the second thing, don't flag it — the coupling is appropriate for now. (Tag: `tight-coupling:`)

5. **Premature seam?** Does the code contain indirection where you *cannot* name the second consumer or implementation — and the indirection doesn't serve testability? If the only implementation is the production one, no mock exists in the test suite, and no ticket describes a second, the seam is paying a navigation tax for nothing. If the seam enables mock injection in tests, it earns its keep regardless of production consumer count. (Tag: `disproportionate:`)

6. **Self-documenting?** Can a maintainer understand the invariants, preconditions, and expected behavior from the code itself? Or does correctness depend on knowing something that isn't expressed in the source? If you need a comment to explain why the code is correct, the code should probably be restructured so the comment becomes unnecessary.

7. **Errors propagated to callers?** When something goes wrong, does the caller receive a signal it can act on? A function that catches an exception, logs it, and returns a default is hiding the failure from the only entity that can make recovery decisions. The fix is propagating the error — not logging harder. (Tag: `silent-failure:` if no signal exists anywhere; `swallowed-error:` if a signal exists but only in logs/metrics, not in the return value.)

8. **Error signals distinguishable?** Can the caller tell *which* thing went wrong from the return value alone? If success and multiple distinct failure modes all map to the same return value (e.g., 0 means "empty result" AND "internal error"), the caller can't react appropriately. A well-engineered function makes every meaningfully different outcome distinguishable without requiring the caller to inspect side channels. (Tag: `ambiguous-interface:`)

9. **Proportionate complexity?** Is the complexity of the implementation proportionate to the complexity of the problem? Simple problems should have simple solutions. If the solution is complex, is the problem genuinely complex, or did the author choose a hard path when an easier one existed?

10. **Testable by construction?** Can the new code be unit-tested in isolation, or does it require standing up the world (database, network, global state) to exercise? If business logic is interleaved with I/O or framework plumbing, the design is making verification harder than it needs to be. Pure logic should be extractable into pure functions.

11. **Naming matches semantics?** Do variable names, function names, and module names accurately describe what the code does? A name that lies — or tells a half-truth — is worse than a bad name, because it actively misleads readers. This goes beyond convention (Style axis) into semantic accuracy: does the name match the actual behavior in all cases, including edge cases and error paths?

12. **Unambiguous interface?** If a caller reads only the function signature, types, name, and documentation — without reading the implementation — will they use it correctly? Can they distinguish all meaningfully different outcomes from the return value alone? Are preconditions expressible through the type system or documented at the declaration site?

13. **Abstraction doesn't leak?** Does the abstraction actually hide its implementation details from callers? If callers must know about initialization order, internal error codes, performance characteristics, or platform-specific behaviors despite the layer of indirection, the abstraction is adding complexity without delivering decoupling. (Tag: `leaky-abstraction:`)

14. **Abstraction doesn't over-hide?** Does the abstraction expose enough for callers to make informed decisions? If callers can't observe degradation, distinguish partial success from full success, or understand why an operation is slow, the abstraction is hiding information they legitimately need. The fix is exposing structured observability hooks without breaking encapsulation. (Tag: `over-sealed:`)

15. **External API calls verified?** For any new calls to APIs outside this package (library functions, framework methods, service clients), has the caller verified the API contract? Find the API documentation or read the function's implementation to confirm: (a) arguments are passed in the correct order and type, (b) return values and error conditions are handled per the API's documented behavior, (c) any preconditions or lifecycle requirements are met. Plausible-looking API calls are cheap to write and expensive to debug when wrong — verify, don't assume.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what's wrong>. → <what it should look like>.
```

For complex findings where the better approach needs explanation:

```
[<confidence>] <file>:L<line>: <tag> <what's wrong>.
  Detail: <explanation of why this approach is suboptimal and what the right approach looks like>
```

## Tags

- `approach:` — Wrong level of abstraction or wrong technique for the problem. The code works but isn't how a seasoned engineer would solve it. The fix requires rethinking, not just editing. Also applies when the diff reinvents a capability the codebase already provides (e.g., hand-rolling retry logic when the shared client already retries with backoff).
- `fragile:` — Relies on an invariant that isn't enforced, or breaks under conditions the author probably didn't consider. Works today, breaks when a reasonable change is made tomorrow. Use this when the problem is *temporal* — the code is correct now but a future modification will silently invalidate an assumption.
- `unhandled:` — A valid input, state, or edge case that the code doesn't account for *today*. Empty collections, null/zero values, boundary values, maximum-size inputs, concurrent access from a second caller. Distinct from `fragile:` — `unhandled:` means the bug exists now for reachable inputs; `fragile:` means the bug will exist after a future change.
- `type-mismatch:` — Data type doesn't match the semantic domain. Using `int` where the domain is non-negative, using a string where an enum would make invalid states unrepresentable, using a signed type where the value is inherently unsigned.
- `opaque:` — Correctness depends on knowledge not present in the source. A future maintainer would need tribal knowledge or git-blame archaeology to understand why this works or what breaks if they change it.
- `disproportionate:` — The solution is more complex than the problem warrants. Not about line count (that's Clean's `shrink:`) — this is about conceptual complexity, indirection layers, or abstraction gymnastics that don't earn their keep.
- `silent-failure:` — Error condition handled by ignoring it, returning a magic value, or continuing in a degraded state without signaling the caller. The system hides problems instead of surfacing them. No signal exists anywhere — not in logs, not in metrics, not in the return value.
- `swallowed-error:` — An error is detected and handled (logged, counted, noted internally) but not propagated to the caller. The caller proceeds as if the operation succeeded. Distinct from `silent-failure:` where no signal exists anywhere. Here a signal exists (in logs, metrics, or internal state) but the caller — the one who needs to make decisions — doesn't see it.
- `tight-coupling:` — Code that depends on a concrete implementation where a boundary or interface would decouple it from future change. The code works, isn't fragile (won't break), and isn't wrong (solves today's problem). But adding a second consumer, backend, or variant requires changing this code and its callers simultaneously. The fix is introducing a seam (interface, callback, configuration) at the point where change is most likely.
- `over-sealed:` — An abstraction that hides information the caller legitimately needs to observe or react to. The inverse of `leaky-abstraction:` — instead of too much bleeding through, too little is visible. Callers can't tell when the underlying system is degraded, can't make informed retry decisions, or can't distinguish success-with-caveats from clean success. The fix is exposing observability hooks without breaking encapsulation (structured results, health signals, progress callbacks).
- `untestable:` — Logic that cannot be exercised without heavyweight integration setup when a design change would make it unit-testable. Pure logic is interleaved with effectful operations (I/O, network, global state). The fix is architectural: separate pure logic from side effects.
- `misleading-name:` — A name (variable, function, module) that doesn't match the code's actual behavior. Distinct from Style axis naming-convention checks (casing, prefixes). This is about semantic accuracy: the name promises one thing, the code does another. A misleading name will cause bugs in code that trusts it.
- `ambiguous-interface:` — A public function or API whose behavior in edge cases is undefined, surprising, or indistinguishable from other outcomes. The caller cannot use the interface correctly without reading the implementation. Examples: returning a sentinel that collides with a valid value, accepting null without documenting the semantics, having undocumented preconditions.
- `leaky-abstraction:` — An interface or wrapper that claims to hide implementation details but still requires callers to know them. The indirection exists but doesn't achieve decoupling. The fix is either: make the abstraction genuinely opaque (translate errors, normalize behavior, hide ordering), or remove the abstraction and let callers use the underlying thing directly.
- `wrong-api-usage:` — A call to an external API that doesn't match the API's actual contract — wrong argument order, missing required setup, unhandled error return, or use of a method that doesn't exist in the installed version. The code compiles (or the method name is plausible) but the behavior at runtime won't match the author's intent. The fix is reading the API documentation and correcting the call.

## Verdict Rules

- `fragile:` scoring ≥ 8 → `FIX REQUIRED` (fragile assumptions break in production eventually)
- `unhandled:` scoring ≥ 8 → `FIX REQUIRED` (a reachable unhandled case is a bug, not a discussion)
- `misleading-name:` scoring ≥ 8 → `FIX REQUIRED` (a misleading name will cause bugs in code that trusts it)
- `swallowed-error:` scoring ≥ 8 → `FIX REQUIRED` (callers making decisions on incomplete information will make wrong decisions)
- `approach:` scoring ≥ 8 → `NEEDS DISCUSSION` (the code works, but the direction deserves a conversation before it ships)
- `ambiguous-interface:` scoring ≥ 8 → `NEEDS DISCUSSION` (callers need clarity, but the right fix may involve tradeoffs)
- `leaky-abstraction:` scoring ≥ 8 → `NEEDS DISCUSSION` (the fix may be "make it opaque" or "remove it entirely" — human decides)
- `wrong-api-usage:` scoring ≥ 8 → `FIX REQUIRED` (incorrect API usage is a bug)
- `tight-coupling:` scoring ≥ 8 → `NEEDS DISCUSSION` (code works today; the coupling only matters if the predicted extension happens)
- `over-sealed:` scoring ≥ 8 → `NEEDS DISCUSSION` (requires judgment on what observability the caller legitimately needs)
- All other tags scoring ≥ 8 → `NEEDS DISCUSSION`
- All findings < 8 → `SHIP` (non-blocking observations)

## Confidence Calibration (Quality axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** The approach is provably wrong — there is a well-known correct technique for this exact problem and the code uses a different one that has known failure modes. Example: using `int` for array indices in a binary search that does `mid - 1` with unsigned-origin counts.
- **9:** Strong engineering consensus that this is the wrong way. Any of 5 senior engineers would independently suggest the same alternative.
- **8:** The code works but introduces a maintenance trap or silent assumption that will bite someone within a year. The better approach is clear.
- **6-7:** Reasonable engineers could disagree on whether this is the right approach. Worth raising for discussion but not blocking.
- **4-5:** Minor preference. The code is fine; this is how you'd do it differently if writing from scratch but not worth changing.
- **2-3:** Extremely minor. Style-adjacent judgment call.
- **1:** Pure taste. Not worth reporting.

## Boundary with Clean axis

If a finding could be tagged as either `shrink:` (Clean) or `disproportionate:` (Quality), it belongs to the axis where the *fix* lives:
- If the fix is "delete code" → Clean
- If the fix is "rethink the approach (and the result happens to be shorter)" → Quality

In practice: Clean findings have an obvious mechanical replacement. Quality findings require judgment about what the replacement *should be*.

## Boundary with Security axis

If a finding involves a type mismatch or fragile assumption that is also exploitable by an attacker, it belongs to Security (which takes priority). Quality catches the same class of issue when the impact is correctness/maintainability rather than exploitability.

## Rules

- Examine both the diff and surrounding code when needed to understand whether an approach is appropriate. Read the function context, the module's existing patterns, and how similar problems are solved elsewhere in the codebase.
- For checklist items that depend on system context (#1 approach, #4/#5 coupling, #6 self-documenting), you SHOULD read callers, callees, and adjacent modules — not just the diff hunks. A change can be internally tidy while duplicating something the codebase already has or breaking a pattern the rest of the system follows.
- Every finding MUST include a concrete alternative — what the code *should* look like. "This feels wrong" is not a finding. "This should use X because Y" is.
- Do NOT flag working code just because you'd write it differently if the difference is purely aesthetic. The threshold is: "would a senior engineer reviewing this PR ask for a change, or would they approve it?"
- Do NOT repeat findings that Security or Clean would catch. If it's exploitable, Security owns it. If it's dead code, Clean owns it. Quality owns the middle ground: code that works, isn't exploitable, isn't dead, but isn't the *right way* to solve the problem.
