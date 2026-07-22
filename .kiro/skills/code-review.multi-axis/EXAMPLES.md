# Examples

## Default invocation

User: `code-review.multi-axis since main`

```
## Review: main..HEAD (3 commits, 5 files)

### Findings

1. [SECURITY 9/10] FAIL: Attacker-controlled bypass. `req.query.role` sets permission level without server-side validation. → Validate against allowlist.
2. [CLEAN 9/10] stale-doc: src/handlers/auth.ts:L10. Docstring says "returns 403 on missing token" but the new code returns 401. → Update docstring.
3. [STYLE 8/10] src/handlers/auth.ts:L38. Bare `any` type on `decoded` variable. Cite: .kiro/steering/clean-code.md "Encode invariants in types, not comments."

### Warnings (confidence < 8)

4. [CLEAN 6/10] shrink: src/handlers/auth.ts:L42. Two identical null checks on `user.id`. Single: `if (!user?.id)`. -2 lines.
5. [SECURITY 5/10] Same class elsewhere. `src/handlers/admin.ts:L88` has a similar unvalidated role check. → Verify separately.

requirements-review: SKIPPED (no requirements found)

### Verdict: FIX REQUIRED (1 security, 1 clean, 1 style)
```

## Selective axis — clean pass

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

security-review: SKIPPED (trivial diff — docs and config only)
requirements-review: Passed. 0 findings.
style-review: Passed. 0 findings.
clean-review: Passed. 0 findings.

### Verdict: SHIP (0 blocking findings)
```


## SOLID findings in a default review

User: `code-review.multi-axis since main`

```
## Review: main..HEAD (5 commits, 8 files)

### Findings

1. [SECURITY 9/10] FAIL: Fails closed. Error in token validation falls through to allow access. → Return 401 on any verification error.
2. [SOLID 8/10] O: src/notifications/NotificationDispatcher.ts:L34. Switch on channel type — adding Slack requires editing this function. → Handler registry keyed by channel enum.
3. [SOLID 8/10] L: src/storage/CachedStore.ts:L72. Subclass throws NotImplementedError on `list()`. Callers of IStore.list() will crash. → Composition with explicit IListable capability.

### Warnings (confidence < 8)

4. [SOLID 7/10] D: src/billing/InvoiceGenerator.ts:L5. Domain class imports StripeClient directly. Untestable without Stripe sandbox. → Accept a PaymentGateway interface.
5. [CLEAN 6/10] shrink: src/notifications/NotificationDispatcher.ts:L50. Duplicated retry loop. Extract to `withRetry()`.

requirements-review: SKIPPED (no requirements found)

### Verdict: FIX REQUIRED (1 security, 1 solid — Liskov ≥ 9 with runtime crash)
```
