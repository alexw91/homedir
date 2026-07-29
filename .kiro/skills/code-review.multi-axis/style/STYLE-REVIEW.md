# Style Review (Sub-skill)

Review the diff for conformance to the project's documented coding conventions. If no explicit conventions docs exist, review against the existing codebase patterns and professional best practices for production-ready software.

NOTE: "Style" here means coding conventions, naming patterns, architectural decisions, and team norms. It does NOT mean internet standards (RFCs, NIST, FIPS). Protocol/spec conformance belongs in the Requirements or Security axes.

## Core Question

**"Does this code follow the project's documented conventions and established patterns?"**

## Input

Refer to `INPUT-CONTRACT.md` for the standard input you receive (diff command or inline diff, commit list, session context).

You will also receive a list of conventions source files to read (steering files, CONTRIBUTING.md, ADRs, linter configs, etc.).

**Local mode:** Read the conventions files, then inspect the diff. Run automated formatters where configured.

**Remote mode:** The diff is provided inline in your prompt. Conventions files are provided or referenced.

## Findings Catalog

1. `naming:` - **Does this follow the project's naming conventions?** Naming conventions (variables, files, exports) that deviate from the established pattern — casing, prefixes, suffixes, or module organization. Check against documented conventions or the prevailing pattern in adjacent files. This is about convention conformance, not semantic accuracy (that's Quality's `misleading-name:`). Verdict ≥ 8: `NEEDS DISCUSSION`.

2. `error-style:` - **Does error handling follow the project's convention?** Error handling approaches that differ from the project's established pattern — different error types, inconsistent propagation patterns, or non-standard recovery mechanisms where the project has a clear norm. Verdict ≥ 8: `NEEDS DISCUSSION`.

3. `doc-style:` - **Is documentation present where expected?** Missing or incorrect documentation where the project expects it — public API docs, module headers, or required annotations that the project's conventions mandate. Verdict ≥ 8: `NEEDS DISCUSSION`.

4. `architecture:` - **Does this respect documented architectural boundaries?** Architectural violations documented in ADRs or steering files — layer bypassing, forbidden dependencies, or structural patterns the team has explicitly decided against. Verdict ≥ 8: `NEEDS DISCUSSION`.

5. `test-style:` - **Does the test structure match conventions?** Test structure that doesn't match the project's test conventions — different describe/it nesting, non-standard setup/teardown patterns, or test naming that breaks the established format. Verdict ≥ 8: `NEEDS DISCUSSION`.

6. `import-style:` - **Do imports follow the established pattern?** Import ordering or module organization that breaks the established pattern — grouping, sorting, aliasing, or path conventions that differ from adjacent files. Verdict ≥ 8: `NEEDS DISCUSSION`.

7. `steering-violation:` - **Does this violate an explicit steering file rule?** Violations of explicit steering file rules (security-sensitive-code, clean-code, etc.) that constitute style/convention violations rather than security or correctness issues. Verdict ≥ 8: `NEEDS DISCUSSION`.

8. `format:` - **Is this auto-fixable formatting?** Formatting issues that should be caught by the project's configured formatter (clang-format, rustfmt, prettier, biome). Run the formatter first; if it fixes the issue, report as `FIXED` rather than a style violation. Verdict ≥ 8: `NEEDS DISCUSSION`.

## Output Format

Follow `OUTPUT-CONTRACT.md` exactly.

For auto-fixed formatting issues:

```
FIXED: <file>. Ran <tool>. <N> formatting changes applied.
```

For manual findings (one line per finding):

```
[<confidence 1-10>] <file>:L<line>: <tag> <violation>. Cite: <source file or "codebase convention">.
```

For complex findings:

```
[<confidence>] <file>:L<line>: <tag> <violation>. Cite: <source>.
  Detail: <multi-line explanation of why this violates the convention and what the correct form is>
```

## Confidence Calibration (Style axis)

See `OUTPUT-CONTRACT.md` for the generic 1-10 scale. For this axis:

- **10:** Violates an explicit, cited rule in a steering file or CONTRIBUTING.md. Unambiguous.
- **9:** Contradicts a clear, consistent pattern used in every other file in the same directory.
- **8:** Strong mismatch with established codebase convention backed by multiple examples.
- **6-7:** Inconsistent with the prevailing pattern but only 2-3 examples to compare against.
- **4-5:** Different from what the reviewer would write, but no documented convention or clear pattern.
- **2-3:** Subjective preference with minimal evidence.
- **1:** Pure taste. No basis in documentation or codebase patterns.

## Rules

- **Run automated formatters first.** If the project has a formatting config file for the changed file types, run the formatter on the changed files and auto-fix:
  - `.clang-format` or `_clang-format` present → run `clang-format -i` on changed `.c`, `.h`, `.cc`, `.cpp` files
  - `rustfmt.toml` or `.rustfmt.toml` present, or the project is a Cargo workspace → run `rustfmt` on changed `.rs` files
  - `prettier.config.*` or `.prettierrc*` present → run `npx prettier --write` on changed files matching its glob
  - `biome.json` present → run `npx biome format --write` on changed files
  - Any other project-specific formatter configured in `package.json` scripts, `Makefile`, or CI config
- Skip anything that linting/formatting tooling already enforces AND was already fixed by the formatter.
- If no explicit conventions docs were provided, sample 2-3 existing files in the same directory as the changed files to establish the local conventions.
- Do NOT flag subjective style preferences with no documented basis.
- Do NOT flag patterns that are consistent with the existing codebase even if they aren't "best practice" globally — the convention IS the codebase pattern.

## Boundaries

- **vs Self-Contained:** Commit message formatting (capitalization, line length, conventional-commits compliance) belongs here. Commit message *accuracy* (does the message match the code?) belongs to Self-Contained.
- **vs Quality:** Naming convention checks (casing, prefixes) belong here. Semantic accuracy of names (the name lies about what the code does) belongs to Quality's `misleading-name:` tag.
- **vs Clean:** Style is about convention conformance (rewrite it to match the pattern). Clean is about unnecessary complexity (remove it). If code follows conventions but is unnecessarily verbose, it's Clean. If code is minimal but breaks naming conventions, it's Style.
