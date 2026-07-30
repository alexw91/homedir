# Examples

## Default invocation

User: `code-review.multi-axis since main`

```
## Review: main..HEAD (3 commits, 5 files)

### Findings

1. [SECURITY 9/10] FAIL: Attacker-controlled bypass. `req.query.role` sets permission level without server-side validation. → Validate against allowlist.
2. [MINIMAL 9/10] stale-doc: src/handlers/auth.ts:L10. Docstring says "returns 403 on missing token" but the new code returns 401. → Update docstring.
3. [STYLE 8/10] src/handlers/auth.ts:L38. Bare `any` type on `decoded` variable. Cite: .kiro/steering/clean-code.md "Encode invariants in types, not comments."

### Warnings (confidence < 8)

4. [MINIMAL 6/10] shrink: src/handlers/auth.ts:L42. Two identical null checks on `user.id`. Single: `if (!user?.id)`. -2 lines.
5. [SECURITY 5/10] Same class elsewhere. `src/handlers/admin.ts:L88` has a similar unvalidated role check. → Verify separately.

requirements-review: Passed. 0 findings.

### Verdict: FIX REQUIRED (1 security, 1 minimal, 1 style)
```

## Selective axis — single axis

User: `code-review.multi-axis security since HEAD~1`

```
## Review: HEAD~1..HEAD (1 commit, 2 files)

### Findings

(none)

### Verdict: SHIP

security-review: Passed. 0 findings.
```

## Full review — all axes pass

User: `code-review.multi-axis since feature-branch-base`

```
## Review: feature-branch-base..HEAD (7 commits, 12 files)

### Findings

(none)

### Warnings (confidence < 8)

1. [STYLE 6/10] src/config.ts:L12. Inconsistent quote style (single vs double). Cite: codebase convention.

style-review: Passed. 0 findings.
minimal-review: Passed. 0 findings.
quality-review: Passed. 0 findings.
security-review: Passed. 0 findings.
requirements-review: Passed. 0 findings.
architecture-review: Passed. 0 findings.
performance-review: Passed. 0 findings.
test-quality-review: Passed. 0 findings.
backwards-compatible-review: Passed. 0 findings.
ready-for-human-review-review: Passed. 0 findings.

### Verdict: SHIP (0 blocking findings)
```

## Architecture and quality findings

User: `code-review.multi-axis architecture quality since main`

```
## Review: main..HEAD (5 commits, 8 files)

### Findings

1. [SECURITY 9/10] FAIL: Fails closed. Error in token validation falls through to allow access. → Return 401 on any verification error.
2. [ARCHITECTURE 8/10] single-responsibility: src/notifications/NotificationDispatcher.ts:L34. Switch on channel type — adding Slack requires editing this function. → Handler registry keyed by channel enum.
3. [QUALITY 8/10] leaky-abstraction: src/storage/CachedStore.ts:L72. IStore abstraction exposes cache-specific methods. Callers must know about caching to use it correctly. → Separate IStore from ICachedStore.

### Warnings (confidence < 8)

4. [ARCHITECTURE 7/10] inverted-dependency: src/billing/InvoiceGenerator.ts:L5. Domain class imports StripeClient directly. Untestable without Stripe sandbox. → Accept a PaymentGateway interface.
5. [MINIMAL 6/10] shrink: src/notifications/NotificationDispatcher.ts:L50. Duplicated retry loop. Extract to `withRetry()`.

requirements-review: Passed. 0 findings.

### Verdict: FIX REQUIRED (1 security, 1 architecture)
```

## Backwards-compatible finding with validated scenario

User: `code-review.multi-axis backwards-compatible since main`

```
## Review: main..HEAD (2 commits, 3 files)

### Findings

1. [BACKWARDS-COMPATIBLE 9/10] removed-option: tls/s2n_security_policies.c:L482. TLS_RSA_WITH_AES_128_CBC_SHA removed from "default" policy cipher list. → Peers supporting only this cipher can no longer negotiate.
  Scenario:
    Setup: Server configured with s2n security policy "default"; peer client only supports TLS_RSA_WITH_AES_128_CBC_SHA.
    Old (before): Handshake succeeds, cipher TLS_RSA_WITH_AES_128_CBC_SHA selected.
    New (after): Handshake fails with no shared cipher suite error.
  Validated: setup exists at old version ✓ | functionality exists at both ✓ | setup identical ✓ | difference observable ✓

### Verdict: FIX REQUIRED (1 backwards-compatible)
```
