# Software Engineering Quality Review (Sub-skill)

Review this diff as a senior engineer who takes pride in craft. Your name will be on this code forever. For each concern, articulate specifically what you'd want to change and why — not vague feelings, but concrete engineering judgment with a proposed better approach.

## Core Question

**"Would I feel proud showing this diff to a principal engineer as an example of my work?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P show <sha>` to inspect committed changes. Read callers, callees, and adjacent modules — not just the diff hunks — to understand whether an approach is appropriate.

**Remote mode:** The diff is provided inline in your prompt. Use the platform-specific file-read recipe for surrounding context if needed.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `stale-cache (new):`, `race-condition (new):`). The same output format, confidence scoring, and verdict rules apply.

1. `approach:` - **Right approach?** Is this solving the problem at the right level? Or is it patching a symptom, working around a limitation, or treating a design problem as a local code problem? Would a senior engineer look at this and say "yes, that's how I'd do it" — or would they say "this works, but you're going in the wrong direction"? Also applies when the diff reinvents a capability the codebase already provides (e.g., hand-rolling retry logic when the shared client already retries with backoff). The code works but isn't how a seasoned engineer would solve it. The fix requires rethinking, not just editing. Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `type-mismatch:` - **Right data type?** Are the types chosen for the job, or inherited from convenience? Would a different representation make the code obviously correct instead of subtly correct? Does the type system enforce the invariants, or do runtime checks compensate for a weak type choice? Using `int` where the domain is non-negative, using a string where an enum would make invalid states unrepresentable, using a signed type where the value is inherently unsigned. Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `unhandled:` - **Edge cases handled?** Does the code handle boundary conditions explicitly, or does it rely on assumptions that aren't enforced? Empty collections, null/zero values, boundary values, maximum-size inputs, concurrent access from a second caller. "Can't happen in practice" is different from "can't happen by construction." A valid input, state, or edge case that the code doesn't account for *today*. Distinct from `fragile:` — `unhandled:` means the bug exists now for reachable inputs. Verdict ≥ 8: `FIX REQUIRED`.

4. `fragile:` - **Will this break under future change?** Relies on an invariant that isn't enforced, or breaks under conditions the author probably didn't consider. Works today, breaks when a reasonable change is made tomorrow. Use this when the problem is *temporal* — the code is correct now but a future modification will silently invalidate an assumption. Fragile assumptions break in production eventually. Verdict ≥ 8: `FIX REQUIRED`.

5. `tight-coupling:` - **Missing seam?** Can you name a concrete second implementation of this dependency that is either (a) already on the roadmap, (b) needed for testing, or (c) an obvious extension that the codebase's domain makes inevitable? If you can name it AND adding it today would require modifying this function's internals, a seam is missing. If you can't name the second thing, don't flag it — the coupling is appropriate for now. Code works today; the coupling only matters if the predicted extension happens. Verdict ≥ 8: `NEEDS DISCUSSION`.

6. `disproportionate:` - **Premature seam or excessive complexity?** The code contains indirection where you *cannot* name the second consumer or implementation — and the indirection doesn't serve testability. If the only implementation is the production one, no mock exists in the test suite, and no ticket describes a second, the seam is paying a navigation tax for nothing. Also: the solution is more complex than the problem warrants — conceptual complexity, indirection layers, or abstraction gymnastics that don't earn their keep. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `opaque:` - **Self-documenting?** Can a maintainer understand the invariants, preconditions, and expected behavior from the code itself? Or does correctness depend on knowing something that isn't expressed in the source? If you need a comment to explain why the code is correct, the code should probably be restructured so the comment becomes unnecessary. Correctness depends on knowledge not present in the source. A future maintainer would need tribal knowledge or git-blame archaeology. Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `silent-failure:` - **Do errors propagate?** When something goes wrong, does the caller receive a signal it can act on? A function that catches an exception, logs it, and returns a default is hiding the failure from the only entity that can make recovery decisions. No signal exists anywhere — not in logs, not in metrics, not in the return value. The fix is propagating the error — not logging harder. Verdict ≥ 8: `FIX REQUIRED`.

9. `swallowed-error:` - **Is the error reaching the decision-maker?** An error is detected and handled (logged, counted, noted internally) but not propagated to the caller. The caller proceeds as if the operation succeeded. Distinct from `silent-failure:` where no signal exists anywhere. Here a signal exists (in logs, metrics, or internal state) but the caller — the one who needs to make decisions — doesn't see it. Callers making decisions on incomplete information will make wrong decisions. Verdict ≥ 8: `FIX REQUIRED`.

10. `ambiguous-interface:` - **Can the caller use this correctly without reading the implementation?** A public function or API whose behavior in edge cases is undefined, surprising, or indistinguishable from other outcomes. Can the caller tell *which* thing went wrong from the return value alone? If success and multiple distinct failure modes all map to the same return value, the caller can't react appropriately. Examples: returning a sentinel that collides with a valid value, accepting null without documenting the semantics, having undocumented preconditions. Verdict ≥ 8: `NEEDS DISCUSSION`.

11. `leaky-abstraction:` - **Does the abstraction actually hide its details?** An interface or wrapper that claims to hide implementation details but still requires callers to know them. The indirection exists but doesn't achieve decoupling. If callers must know about initialization order, internal error codes, performance characteristics, or platform-specific behaviors despite the layer of indirection, the abstraction is adding complexity without delivering decoupling. The fix is either: make the abstraction genuinely opaque, or remove it and let callers use the underlying thing directly. Verdict ≥ 8: `NEEDS DISCUSSION`.

12. `over-sealed:` - **Does the abstraction hide too much?** Does the abstraction expose enough for callers to make informed decisions? If callers can't observe degradation, distinguish partial success from full success, or understand why an operation is slow, the abstraction is hiding information they legitimately need. The fix is exposing structured observability hooks without breaking encapsulation. Requires judgment on what observability the caller legitimately needs. Verdict ≥ 8: `NEEDS DISCUSSION`.

13. `untestable:` - **Can this be unit-tested in isolation?** Logic that cannot be exercised without heavyweight integration setup when a design change would make it unit-testable. Business logic is interleaved with I/O or framework plumbing. Pure logic should be extractable into pure functions. The fix is architectural: separate pure logic from side effects. Verdict ≥ 8: `NEEDS DISCUSSION`.

14. `misleading-name:` - **Does the name match the behavior?** A name (variable, function, module) that doesn't match the code's actual behavior in all cases, including edge cases and error paths. Distinct from Style axis naming-convention checks (casing, prefixes). This is about semantic accuracy: the name promises one thing, the code does another. A misleading name will cause bugs in code that trusts it. Verdict ≥ 8: `FIX REQUIRED`.

15. `wrong-api-usage:` - **Is the external API call correct?** A call to an external API that doesn't match the API's actual contract — wrong argument order, missing required setup, unhandled error return, or use of a method that doesn't exist in the installed version. The code compiles (or the method name is plausible) but the behavior at runtime won't match the author's intent. The fix is reading the API documentation and correcting the call. Verdict ≥ 8: `FIX REQUIRED`.

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

## Confidence Calibration (Quality axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** The approach is provably wrong — there is a well-known correct technique for this exact problem and the code uses a different one that has known failure modes. Example: using `int` for array indices in a binary search that does `mid - 1` with unsigned-origin counts.
- **9:** Strong engineering consensus that this is the wrong way. Any of 5 senior engineers would independently suggest the same alternative.
- **8:** The code works but introduces a maintenance trap or silent assumption that will bite someone within a year. The better approach is clear.
- **6-7:** Reasonable engineers could disagree on whether this is the right approach. Worth raising for discussion but not blocking.
- **4-5:** Minor preference. The code is fine; this is how you'd do it differently if writing from scratch but not worth changing.
- **2-3:** Extremely minor. Style-adjacent judgment call.
- **1:** Pure taste. Not worth reporting.

## Rules

- Examine both the diff and surrounding code when needed to understand whether an approach is appropriate. Read the function context, the module's existing patterns, and how similar problems are solved elsewhere in the codebase.
- For items that depend on system context (#1 approach, #5/#6 coupling, #7 self-documenting), you SHOULD read callers, callees, and adjacent modules — not just the diff hunks.
- Every finding MUST include a concrete alternative — what the code *should* look like. "This feels wrong" is not a finding. "This should use X because Y" is.
- Do NOT flag working code just because you'd write it differently if the difference is purely aesthetic. The threshold is: "would a senior engineer reviewing this PR ask for a change, or would they approve it?"
- Do NOT repeat findings that Security or Minimal would catch. If it's exploitable, Security owns it. If it's dead code, Minimal owns it. Quality owns the middle ground: code that works, isn't exploitable, isn't dead, but isn't the *right way* to solve the problem.

## Boundaries

- **vs Minimal:** If the fix is "delete code" → Minimal. If the fix is "rethink the approach (and the result happens to be shorter)" → Quality. Minimal findings have an obvious mechanical replacement. Quality findings require judgment about what the replacement *should be*.
- **vs Security:** If a finding involves a type mismatch or fragile assumption that is also exploitable by an attacker, it belongs to Security (which takes priority). Quality catches the same class of issue when the impact is correctness/maintainability rather than exploitability.
