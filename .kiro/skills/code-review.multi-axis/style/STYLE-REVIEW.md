# Style Review (Sub-skill)

Review the diff for conformance to the project's documented coding conventions. If no explicit conventions docs exist, review against the existing codebase patterns and professional best practices for production-ready software.

NOTE: "Style" here means coding conventions, naming patterns, architectural decisions, and team norms. It does NOT mean internet standards (RFCs, NIST, FIPS). Protocol/spec conformance belongs in the Requirements or Security axes.

## Inputs

You will receive:
1. The diff content (pre-computed by the orchestrator)
2. A list of conventions source files to read (steering files, CONTRIBUTING.md, ADRs, linter configs, etc.)

## Process

1. Read all provided conventions source files.
2. Read the diff.
3. **Run automated formatters first.** If the project has a formatting config file for the changed file types, run the formatter on the changed files and auto-fix:
   - `.clang-format` or `_clang-format` present → run `clang-format -i` on changed `.c`, `.h`, `.cc`, `.cpp` files
   - `rustfmt.toml` or `.rustfmt.toml` present, or the project is a Cargo workspace → run `rustfmt` on changed `.rs` files
   - `prettier.config.*` or `.prettierrc*` present → run `npx prettier --write` on changed files matching its glob
   - `biome.json` present → run `npx biome format --write` on changed files
   - Any other project-specific formatter configured in `package.json` scripts, `Makefile`, or CI config
   Report each auto-fixed file as a `FIXED` finding (not a style violation). If the formatter is not installed or fails, report the formatting issue as a normal style finding instead.
4. For each hunk in the diff, check whether it violates a documented convention or an established codebase pattern.
5. Skip anything that linting/formatting tooling already enforces AND was already fixed in step 3.
6. If no explicit conventions docs were provided, sample 2-3 existing files in the same directory as the changed files to establish the local conventions (naming, error handling patterns, test structure, import style).

## Format

For auto-fixed formatting issues:

```
FIXED: <file>. Ran <tool>. <N> formatting changes applied.
```

For manual findings (one line per finding):

```
[<confidence 1-10>] <file>:L<line>: <violation>. Cite: <source file or "codebase convention">.
```

For complex findings that need explanation, use:

```
[<confidence>] <file>:L<line>: <violation>. Cite: <source>.
  Detail: <multi-line explanation of why this violates the convention and what the correct form is>
```

## What to flag

- Naming conventions (variables, files, exports) that deviate from the established pattern
- Error handling approaches that differ from the project's convention
- Missing or incorrect documentation where the project expects it
- Architectural violations (e.g., layer bypassing documented in ADRs)
- Test structure that doesn't match the project's test conventions
- Import ordering or module organization that breaks the established pattern
- Violations of explicit steering file rules (security-sensitive-code, clean-code, etc.)

## What NOT to flag

- Formatting issues that were already auto-fixed in step 3 — report those as `FIXED`, not violations
- Subjective style preferences with no documented basis
- Patterns that are consistent with the existing codebase even if they aren't "best practice" globally — the convention IS the codebase pattern

## Verdict

Follow `OUTPUT-CONTRACT.md` exactly.

**Confidence calibration (Style axis):**

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Violates an explicit, cited rule in a steering file or CONTRIBUTING.md. Unambiguous.
- **9:** Contradicts a clear, consistent pattern used in every other file in the same directory.
- **8:** Strong mismatch with established codebase convention backed by multiple examples.
- **6-7:** Inconsistent with the prevailing pattern but only 2-3 examples to compare against.
- **4-5:** Different from what the reviewer would write, but no documented convention or clear pattern.
- **2-3:** Subjective preference with minimal evidence.
- **1:** Pure taste. No basis in documentation or codebase patterns.
