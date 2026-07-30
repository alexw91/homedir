# Performance Review (Sub-skill)

Review the diff for immediately available performance improvements. Think like a systems engineer who reads hot paths for a living: unnecessary work, avoidable allocations, suboptimal data structures, and missed batching opportunities. Only flag things that have a clear, local fix within this repository.

## Core Question

**"Is this code doing work it doesn't need to, copying data it could borrow, or making N calls where one would do?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

**Local mode:** Use `git -P diff @{upstream} --name-only` to identify changed files. Read the full function context around changed lines — performance issues often depend on loop boundaries, call frequency, or data sizes that aren't visible in the diff hunks alone. Check for hot-path indicators: is the changed code inside a loop, a request handler, or a per-record callback?

**Remote mode:** The diff is provided inline in your prompt. Use the platform-specific file-read recipe to read callers and determine whether a function is on a hot path.

## Findings Catalog

The Findings Catalog is not exhaustive. If you identify a performance concern that answers the Core Question but doesn't match any numbered item, report it using a descriptive ad-hoc tag of your choosing suffixed with `(new)` (e.g., `blocking-main-thread (new):`, `gc-pressure (new):`). The same output format, confidence scoring, and verdict rules apply.

### Algorithmic Complexity

1. `complexity:` - **Is there a better algorithm or data structure that reduces the runtime complexity?** An O(n²) operation where an O(n log n) or O(n) alternative exists using a different data structure (hash map, sorted set, heap). A nested loop doing lookups that a single-pass approach with a lookup table would eliminate. The fix is switching to the better algorithm/data structure. Only flag when the improvement is at least one complexity class and the input size is non-trivial (not a 5-element list). Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `linear-search:` - **Is a linear scan used where an indexed lookup exists?** Iterating through a list or array to find an element when the data could be stored in (or already exists in) a hash map, set, or sorted structure that supports O(1) or O(log n) lookup. Especially problematic when the search is inside a loop, making the outer operation O(n²). The fix is pre-indexing the data or switching the container type. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Unnecessary Work

3. `eager-computation:` - **Is computation performed unconditionally when it's only needed on some paths?** A value is calculated, an object is constructed, or a remote call is made before checking whether the result will actually be used. Signals: computation above an early-return guard, allocation before a conditional branch that may not need it, or a database query whose result is only consumed inside one arm of an `if`. The fix is deferring the work past the condition or making it lazy. Verdict ≥ 8: `NEEDS DISCUSSION`.

4. `redundant-computation:` - **Is the same result computed more than once when it could be cached or hoisted?** A pure function called with the same arguments inside a loop. A regex compiled on every invocation instead of once at module load. A derivation recomputed on every access when the inputs haven't changed. The fix is hoisting, memoizing, or caching the result. Verdict ≥ 8: `NEEDS DISCUSSION`.

5. `unnecessary-iteration:` - **Does the code iterate further than needed?** Processing continues after the answer is known (missing `break` or early return). A `filter` followed by `find` when a single pass would suffice. Sorting an entire collection when only the top-k elements are needed (use a heap). The fix is short-circuiting or using a more targeted operation. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Memory and Allocation

6. `avoidable-copy:` - **Is data copied when a reference, slice, or view would suffice?** Cloning a large buffer to pass ownership when a borrow or slice covers the use case. Converting to a new string just to compare or hash. Copying into a Vec when an iterator would compose without materializing. Read-only consumers don't need owned data. The fix is passing a reference, slice, or zero-copy view. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `allocation-in-loop:` - **Is memory allocated inside a loop when it could be allocated once and reused?** Creating a new buffer, string builder, temporary collection, or object on every iteration when the same allocation could be cleared and reused across iterations. The fix is hoisting the allocation outside the loop and resetting/clearing between iterations. Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `oversized-allocation:` - **Is significantly more memory allocated than needed?** Pre-allocating a collection with a capacity vastly larger than the expected size. Using a data structure with high per-element overhead (linked list, tree) when a compact alternative (array, flat buffer) would serve the access pattern. The fix is right-sizing the allocation or choosing a more compact representation. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Batching and I/O

9. `n-plus-one:` - **Are N individual calls made where a single batch call would work?** A loop that makes one database query, API call, or I/O operation per element when a batch API exists. Issuing individual HTTP requests inside a loop instead of a bulk endpoint. Writing records one at a time instead of using batch/bulk insert. The fix is collecting inputs and making one batch call. Verdict ≥ 8: `NEEDS DISCUSSION`.

10. `chatty-io:` - **Are multiple round-trips made where fewer would suffice?** Multiple sequential reads/writes to the same file or socket that could be combined. Fetching related data in separate calls when a join or compound query would return it in one. Sending many small messages when a single aggregated message would carry the same information. The fix is combining I/O operations to reduce round-trip overhead. Verdict ≥ 8: `NEEDS DISCUSSION`.

### API Choice

11. `suboptimal-api:` - **Is there a more efficient API for this operation at the cost of more state tracking?** Using a high-level convenience API that does extra work (re-parsing, re-authenticating, re-connecting) on every call when a lower-level API that maintains state across calls would avoid that overhead. Using `putItem` in a loop instead of `batchWriteItem`. Reopening a file for each write instead of holding a handle. The fix is using the more efficient API and managing the associated state. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Concurrency and Contention

12. `serial-when-parallel:` - **Are independent operations serialized unnecessarily?** Sequential operations that don't depend on each other's results and could run concurrently. Awaiting N independent promises one at a time instead of `Promise.all()`. Sequential HTTP calls where neither depends on the other's result. Processing independent work items in a `for` loop when a thread pool or parallel stream would saturate available cores. The fix is parallelizing the independent work. Verdict ≥ 8: `NEEDS DISCUSSION`.

13. `contention:` - **Is a shared lock held wider than necessary?** A lock, mutex, or synchronized block held across I/O or long-running computation, forcing other threads/coroutines to wait. A global lock where per-key or per-shard locking would reduce contention. A read-write lock used exclusively for writes when readers vastly outnumber writers. Signals: lock acquired before a network call, entire method synchronized when only one field access requires exclusion. The fix is narrowing the critical section or using finer-grained locking. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Data Layout and Access Patterns

14. `cache-hostile:` - **Does the data layout defeat CPU cache locality?** Iterating over a linked list or pointer-chasing through heap-allocated nodes when a flat array would give sequential access. Struct-of-arrays vs array-of-structs mismatch for the dominant access pattern. Random-access jumps through a large data structure when the same work could be done in a single sequential pass. Column-major access on a row-major array (or vice versa). The fix is restructuring data for sequential access on the hot path. Verdict ≥ 8: `NEEDS DISCUSSION`.

15. `false-sharing:` - **Are independent per-thread variables packed into the same cache line?** Multiple threads writing to adjacent memory locations (same 64-byte cache line) without realizing they're contending. Per-thread counters, flags, or state packed into adjacent struct fields or array slots. Signals: a struct with per-thread fields and no padding, atomic counters in adjacent array indices. The fix is cache-line padding between per-thread state or separating into per-thread allocations. Most relevant in C/C++/Rust; less common in managed languages but can appear in lock-free data structures. Verdict ≥ 8: `NEEDS DISCUSSION`.

### Serialization and Format Overhead

16. `serialize-deserialize:` - **Is data round-tripped through a format unnecessarily?** Data is serialized to a transport format and immediately deserialized back in the same process or between tightly-coupled components. `JSON.stringify()` followed by `JSON.parse()` to deep-clone (use `structuredClone` or a manual copy). Converting to a string representation to pass to another function that immediately parses it back. Encoding to bytes just to hash when a structured hasher would work directly. The fix is passing the structured data directly or using a cheaper cloning mechanism. Verdict ≥ 8: `NEEDS DISCUSSION`.

17. `format-overhead:` - **Is a heavyweight format used where a lighter one would suffice?** Using XML or JSON with full schema validation on an internal, non-durable, same-process data path where a compact binary format, raw struct, or simple delimiter would work. Parsing a full CSV row with a library when you only need one column (use split + index). Pretty-printing output that will be machine-parsed downstream. The fix is using the lightest representation that satisfies the actual requirements of the consumer — reserving heavyweight formats for external boundaries and durable storage. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

Finding line format for this axis:

```
[<confidence 1-10>] <tag> <file>:L<line>. <what's inefficient>. → <more efficient alternative>.
```

For complex findings where the performance impact needs explanation:

```
[<confidence>] <tag> <file>:L<line>. <what's inefficient>. → <more efficient alternative>.
  Detail: <explanation of the performance cost — O(?) complexity, expected data size, call frequency, or measured/estimated impact>
```

Examples:

```
[9] complexity: src/search/filter.ts:L34. Nested loop checks membership in an array for each element — O(n*m). → Convert the filter list to a Set before the loop for O(n) total.
[8] eager-computation: src/api/handler.ts:L12. Expensive permission matrix is built before checking whether the request requires authorization at all. → Move the matrix construction below the early-return for public endpoints.
[7] redundant-computation: src/render/template.ts:L88. Regex is compiled on every call to formatDate(). Called ~1000x per page render. → Hoist the regex to module scope as a constant.
[9] avoidable-copy: src/crypto/verify.rs:L45. Input buffer is cloned into a Vec just to slice the first 32 bytes. → Use &input[..32] directly — the function only reads it.
[8] allocation-in-loop: src/batch/process.ts:L22. New Buffer allocated per record inside a 10k-record loop. → Allocate once before the loop, clear() between iterations.
[8] n-plus-one: src/db/users.ts:L55. One SELECT per user ID in a loop (N+1 pattern, up to 500 users). → Use a single WHERE id IN (...) query.
[7] linear-search: src/config/lookup.ts:L30. Array.find() on a 200-element policy list inside a per-request handler. → Index policies into a Map<string, Policy> at startup.
[8] suboptimal-api: src/s3/upload.ts:L15. Individual PutObject calls in a loop for 100+ small files. → Use S3 batch/multipart upload or parallelize with Promise.all().
[6] chatty-io: src/log/flush.ts:L40. Three sequential write() calls to the same fd per log line. → Buffer and write once per line.
[8] serial-when-parallel: src/api/enrich.ts:L20. Three independent API calls awaited sequentially (user, permissions, config) — total latency is sum of all three. → Promise.all([fetchUser(), fetchPerms(), fetchConfig()]) for max-of-three latency.
[7] contention: src/cache/store.rs:L15. Global mutex held across a 50ms network fetch to the backing store. All other cache reads block. → Narrow the lock to the cache-map update only; fetch outside the critical section.
[8] cache-hostile: src/physics/particles.c:L30. Linked list of Particle* iterated every frame for position updates — pointer chasing defeats prefetch. → Store particles in a flat array; iterate sequentially.
[6] false-sharing: src/metrics/counters.c:L5. Per-thread counters packed in adjacent uint64_t array slots — all on the same cache line. → Pad each counter to 64 bytes or use thread-local storage.
[8] serialize-deserialize: src/handler/clone.ts:L12. Deep clone via JSON.parse(JSON.stringify(config)) on every request. → structuredClone(config) or a manual shallow copy (config is 3 flat fields).
[7] format-overhead: src/internal/rpc.ts:L88. Internal inter-module call serializes args to JSON and parses on the other side — both are in the same process. → Pass the object directly; JSON adds ~2ms per call at 1000 calls/sec.
```

## Confidence Calibration (Performance axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** The inefficiency is on a measured hot path, the data size is known to be large, and the improvement is provably better by at least one complexity class.
- **9:** Clear algorithmic improvement (e.g., O(n²) → O(n)) with evidence the input size is non-trivial from the code or its context (loop bounds, collection types, batch sizes).
- **8:** Strong performance smell with reasonable assumptions about call frequency or data size. A senior engineer would flag this in review.
- **6-7:** Likely improvement but depends on runtime characteristics the reviewer can't see (actual data sizes, call frequency, whether the hot path is really hot).
- **4-5:** Micro-optimization. Measurably faster in a benchmark but unlikely to matter at the system level.
- **2-3:** Pedantic. The difference is nanoseconds or single allocations in cold paths.
- **1:** Purely theoretical. The optimization would make the code harder to read for no observable benefit.

## Rules

- Only flag performance issues introduced or worsened by the diff. Pre-existing inefficiencies in untouched code are out of scope.
- Every finding MUST propose a concrete fix. "This is slow" is not a finding. "Replace the nested loop with a Map lookup for O(n) instead of O(n²)" is.
- Do NOT flag micro-optimizations on cold paths. If the code runs once at startup, once per deploy, or once per manual user action, the constant-factor improvement doesn't matter.
- Do NOT flag issues that require changes outside the repository. "Migrate from Postgres to DynamoDB" is not a code review finding.
- Do NOT flag speculative caching (memoizing a function that might be called once). Only flag redundant computation when you can see evidence of repeated calls (a loop, a hot handler, a per-request path).
- When flagging algorithmic complexity, state the current and proposed complexity explicitly (O(n²) → O(n log n)).
- Consider data size. An O(n²) algorithm on a 5-element fixed-size list is fine. An O(n²) algorithm on a user-controlled or growing collection is a finding.
- Read callers to determine whether code is on a hot path. A function called from a tight loop or a per-request handler has different performance requirements than one called at startup.

## Boundaries

Overlap between axes is acceptable and expected. Multiple axes reporting the same issue from different lenses is a stronger signal, not a problem. The orchestrator does not deduplicate across axes.

- **vs Quality:** An O(n²) algorithm might also be flagged by Quality as `approach:` ("wrong way to solve the problem"). That's fine — Performance focuses on the runtime cost; Quality focuses on whether a senior engineer would choose this approach at all.
- **vs Security:** An algorithmic complexity issue exploitable as a DoS vector will be flagged by Security too. Performance catches the same pattern from a latency/cost perspective.
- **vs Architecture:** A missing batch API might also be flagged by Architecture as a structural issue requiring a new module boundary. Performance flags the immediate "use the batch API that exists" fix.
- **vs Clean:** Dead code that also wastes CPU may be flagged by Clean for deletion and by Performance for the wasted cycles. Both are valid lenses.
