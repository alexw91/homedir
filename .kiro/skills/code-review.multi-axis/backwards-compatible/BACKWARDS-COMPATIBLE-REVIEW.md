# Backwards Compatible Review (Sub-skill)

Review the diff as the person who gets paged when a library upgrade breaks production. Your job is to find any change that could surprise an existing consumer or network peer who upgrades to this version without modifying their own code or configuration. Assume peers are sloppy but not adversarial — brittle implementations that rely on incidental behaviors, not just spec-compliant ones.

## Core Question

**"If this change were deployed to production as-is, and existing API consumers and network peers made zero changes, could anyone be broken?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Run the diff command to get the changes. Read public header files, exported module interfaces, and protocol-handling code to understand what's exported vs internal. Trace internal changes through to public API behavior when the connection isn't obvious from the diff alone.

**Remote mode:** The diff is provided inline. Use the platform-specific file-read recipe to inspect public API definitions (header files, index.ts exports, public interfaces) and protocol state machine code when needed to assess whether an internal change affects observable behavior.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `removed-default (new):`, `timing-change (new):`). The same output format, confidence scoring, and verdict rules apply.

### API Surface (library consumers)

1. `removed-symbol:` - **Is a public symbol gone?** A public function, type, constant, enum variant, or exported module that existed in the previous version has been removed or renamed. Existing callers will fail to compile or link. Also applies to removing a method from a public interface/trait that implementors depend on. Verdict ≥ 8: `FIX REQUIRED`.

2. `signature-change:` - **Did the calling convention change?** A public function's parameter types, parameter count, parameter order, or return type changed. Existing callers pass the old arguments and get a compile error or silent type coercion. Includes changing optional parameters to required, or adding required parameters without defaults. Verdict ≥ 8: `FIX REQUIRED`.

3. `semantic-change:` - **Same call, different result?** An internal change alters the observable behavior of a public API: same inputs now produce different outputs, different side effects, or different ordering. The caller's code compiles fine but behaves differently at runtime. Must trace from the internal change through to an exported function to confirm observability. Verdict ≥ 8: `FIX REQUIRED`.

4. `new-error:` - **Does this function fail in new ways?** A public function now returns or throws an error condition it didn't before. Existing callers don't handle this error path — they either crash, propagate an unexpected exception, or silently get a value they don't understand. Verdict ≥ 8: `FIX REQUIRED`.

5. `narrowed-input:` - **Are previously-valid inputs now rejected?** A public function now rejects inputs it previously accepted. Stricter validation, tighter range checks, or newly-enforced preconditions that would cause existing callers (who pass previously-acceptable values) to get errors. Verdict ≥ 8: `FIX REQUIRED`.

6. `widened-output:` - **Can the output surprise a caller?** The return type or output enum was extended with new variants, new fields, or new possible values that existing callers may not handle. A switch/match on the return value that was previously exhaustive now has an unhandled case. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Wire/Protocol Surface (network peers)

7. `removed-option:` - **Can a peer no longer negotiate?** A negotiable option (cipher suite, signature algorithm, protocol version, compression method, extension) was removed from the default offering. A peer that only supports the removed option can no longer establish a connection. Verdict ≥ 8: `FIX REQUIRED`.

8. `stricter-validation:` - **Will sloppy peers be rejected?** A new check rejects messages, field values, or message sequences that the old code accepted. The peer hasn't changed, but this library now refuses to talk to it. Assume peers with sloppy but non-adversarial implementations: non-compliant extension lengths, unexpected message ordering, deprecated fields still sent, post-handshake messages in unexpected contexts. Verdict ≥ 8: `FIX REQUIRED`.

9. `changed-wire-bytes:` - **Are different bytes sent on the wire?** The encoding of a field changed, extension ordering changed, different values are sent in protocol fields, or new mandatory extensions are included that old peers don't understand. Any change that would make a packet capture of "before" and "after" differ, even if both are spec-compliant. A peer relying on the previous byte pattern (even if that reliance is technically wrong) would observe different behavior. Verdict ≥ 8: `FIX REQUIRED`.

10. `state-machine-change:` - **Is the message sequence different?** The expected or produced sequence of protocol messages changed. The library now sends messages in a different order, expects a different response to a valid message, or transitions to a different state on input that previously led elsewhere. A peer following the old expected sequence gets an unexpected message or timeout. Verdict ≥ 8: `FIX REQUIRED`.

11. `reordered-preference:` - **Will negotiation select differently?** Preference list ordering changed (cipher suites, signature algorithms, supported groups, ALPN protocols). Negotiation still succeeds, but a different option is selected than before. Peers that are sensitive to which specific option is chosen (performance, compatibility with downstream systems) observe different behavior. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Finding Validation (mandatory)

This axis is prone to false positives from speculative reasoning. Before reporting ANY finding, you MUST construct and validate a concrete break scenario. Do NOT report a finding unless you can fill in all fields below and confirm all validation checks pass.

**Required scenario structure for every finding:**

```
Behavior Change:
- Setup: [Exact configuration, API call with parameters, or peer behavior
  that is identical across both versions. Must be achievable on the OLD
  version without the change under review.]
- Old behavior (before this diff): [What happened with the above setup]
- New behavior (after this diff): [What happens with the above setup]
```

**Validation checklist (all MUST pass or the finding is discarded):**

1. **Setup exists at the old version.** The configuration, input, or peer behavior described in "Setup" is actually possible on the old library version *without* this diff. If the setup requires functionality introduced by this diff, it is NOT a breaking change.
2. **All referenced functionality exists at both points in time.** Every API, config option, protocol feature, or code path referenced in the scenario exists in both the old and new versions. If the diff introduces a new config option, new API, or new protocol feature, only existing callers of *pre-existing* functionality can be broken.
3. **The setup is genuinely identical.** The consumer/peer does not need to change anything between versions. Same function call, same parameters, same config file, same wire messages. If the "break" requires the user to opt into new behavior (e.g., selecting a newly-created TLS policy, calling a newly-added function, enabling a new flag), it is NOT a breaking change.
4. **The behavioral difference is observable.** The old and new behaviors produce a measurably different outcome: different return value, different error, failed negotiation, different wire bytes, connection refusal.

**If any check fails, do NOT report the finding.** Common false positive patterns:
- Flagging a new enum variant/policy/option as breaking when no existing code path selects it by default
- Flagging changes to code that's only reachable through newly-added API surface
- Flagging "stricter validation" when the strict check is behind a new opt-in flag
- Assuming a configuration existed before the diff when it was actually introduced by the diff

## Confidence Modifiers

These rules adjust confidence regardless of the catalog item:

- **Intentional behavioral change:** If the diff's commit message or stated purpose explicitly describes the flagged behavioral change as its goal (e.g., "Remove support for TLS 1.0", "Reject invalid content types"), drop confidence to warning range (5-7). The author has already considered the consequences; the finding serves as documentation rather than a surprise.
- **New opt-in configuration:** If the breaking change is behind a new opt-in config option that didn't exist before, it is NOT a finding. There are no existing users of a newly-created opt-in. Only flag if the option is opt-*out* (enabled by default).

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Every finding MUST include the validated break scenario inline. The finding line provides the summary; the Detail block provides the scenario that passed validation.

Finding line format for this axis:

```
[<confidence 1-10>] <file>:L<line>: <tag> <what changed>. → <who breaks and how>.
  Scenario:
    Setup: <exact config/input/peer behavior identical across both versions>
    Old (before): <what happened with this setup before this diff>
    New (after): <what happens with this setup after this diff>
  Validated: setup exists at old version ✓ | functionality exists at both ✓ | setup identical ✓ | difference observable ✓
```

For simpler findings where the break is obvious (e.g., public symbol deleted):

```
[<confidence 1-10>] <file>:L<line>: <tag> <what changed>. → <who breaks and how>.
  Scenario:
    Setup: <caller uses the removed/changed symbol>
    Old (before): <compiles/works>
    New (after): <compile error / link error / runtime failure>
  Validated: ✓ all checks pass
```

If any validation check fails during your internal reasoning, do NOT emit the finding. Silently discard it.

## Confidence Calibration (Backwards Compatible axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Public symbol deleted. Or: cipher suite removed from default list (provable from the diff, no ambiguity).
- **9:** Public function signature changed (new required parameter, changed return type). Or: new validation check that provably rejects input the old code accepted.
- **8:** Internal change that alters observable public API behavior — the trace from internal to public is clear and short (1-2 function calls deep).
- **6-7:** Internal change that *probably* affects external behavior but the trace is long or crosses module boundaries. Or: intentional behavioral change (commit message says so) — serves as documentation.
- **4-5:** Preference reordering where the practical impact depends on peer behavior the reviewer can't observe. Or: wire-byte change that's spec-compliant and likely harmless but technically detectable.
- **2-3:** Theoretical break that requires a peer implementation so broken it would fail interop tests.
- **1:** Change is technically observable on the wire but no real-world implementation would notice.

## Rules

- Trace internal changes to their public-API or wire-level consequences. An internal refactor is only a finding if you can articulate the observable difference for a consumer or peer.
- For protocol code: think about what the *previous version* sent/accepted on the wire. If the new version sends different bytes or rejects something the old version accepted, that's a finding regardless of whether the new behavior is more correct.
- Read public API definitions (header files, export lists, interface declarations) to determine what's exported. Only flag changes to exported symbols or their observable behavior.
- Do NOT flag new opt-in features as breaking. A config option that didn't exist before has no existing users.
- Do NOT flag bug fixes that make behavior match documented semantics — unless the buggy behavior is so old that consumers likely depend on it (in which case, flag at medium confidence as `semantic-change:`).
- Do NOT flag changes to internal-only symbols that have no path to observable behavior. If you can't trace the change to a public API or wire difference, it's not a compatibility finding.

## Boundaries

- **vs Security:** If a backwards-incompatible change is a security hardening (rejecting attacks, closing vulnerabilities), Security owns the "is this the right fix?" question. This axis owns "will this break existing peers?" Both can flag the same change — that's a stronger signal that the fix needs a migration path or feature flag.
- **vs Quality:** Quality's `fragile:` tag catches code that will break under *future* change. This axis catches code that breaks *existing consumers today* upon deployment. If the break requires a future code change to manifest → Quality. If it manifests immediately upon upgrading → Backwards Compatible.
- **vs Architecture:** Architecture's `over-exposed:` catches APIs that shouldn't be public. This axis protects APIs that *are* public (regardless of whether they should be). Removing something that shouldn't have been public in the first place is still a backwards-incompatible break.
