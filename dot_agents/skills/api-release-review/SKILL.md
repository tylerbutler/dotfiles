---
name: API Release Review
description: Use when preparing a library or API for initial public release - conducts a conversational review covering public surface, type opacity, naming stability, error design, documentation, dependency exposure, and future-proofing before any 1.0 or first release
---

<required>
*CRITICAL* Add the following steps to your Todo list using TodoWrite:

1. Gather library context
2. Review public API surface
3. Review type opacity and visibility
4. Review naming stability
5. Review error type design
6. Review documentation completeness
7. Review dependency exposure
8. Review future-proofing and extensibility
9. Review versioning readiness
10. Apply language-specific checks
11. Present findings and ask user how to proceed
</required>

# Overview

This skill guides a conversational pre-release review of a library or API before its first public release. The goal is to identify decisions that are hard to reverse once users depend on them.

The review is **read-only by default** — present findings and let the user decide what to act on.

---

# Step 1: Gather Library Context

Before reviewing, ask the user (or infer from the codebase):

- What language/ecosystem is this?
- What is the library's purpose in one sentence?
- Who is the intended audience (internal team, public OSS, published package)?
- Is there an existing public API surface (re-export barrel, `.mli` file, `gleam.toml` internal_modules, etc.)?
- What version will this be released as (0.1.0, 1.0.0, etc.)?

Use this context to calibrate severity. A 0.1.0 release has more flexibility than a 1.0.0.

---

# Step 2: Public API Surface

**Goal**: Everything public should be intentionally public. Everything else should be hidden.

Check:
- Are there internal implementation details accidentally exported/public?
- Is there a clear "entry point" (main module, barrel file, re-export list)?
- Are test helpers, internal utilities, or scaffolding excluded from the public surface?
- Does the exported surface match the documentation?

Ask: *"If a user imports only the top-level module, what do they get? Is that exactly what you want?"*

---

# Step 3: Type Opacity and Visibility

**Goal**: Types that users shouldn't construct or pattern-match on should be opaque.

Check:
- Are internal record/struct fields hidden from users?
- Can users construct types they shouldn't be able to (bypassing invariants)?
- Can users pattern-match on types that might gain variants later (breaking their code)?
- Are "handle" or "context" types properly opaque?

Ask: *"For each public type: does a user need to construct it, or just use it? If just use it, consider making it opaque."*

See language-specific section below for how to enforce this per-language.

---

# Step 4: Naming Stability

**Goal**: Names you ship are names you're stuck with. Choose carefully.

Check:
- Are names clear to someone with no prior context?
- Are abbreviations consistent and unambiguous?
- Do function names follow the ecosystem's conventions (e.g., `parse` vs `from_string` vs `decode`)?
- Are there any placeholder or "temporary" names that slipped through?
- Is naming consistent across the API (e.g., all getters use `get_` or none do)?
- Do module/package/namespace names reflect the library's purpose and won't clash with common names?

Ask: *"Read the public API list aloud as if explaining it to a new user. Does anything sound wrong or confusing?"*

---

# Step 5: Error Type Design

**Goal**: Errors should be informative, stable, and appropriately public.

Check:
- Are error types public and documented?
- Do error variants expose enough detail to be actionable, but not too much internal state?
- Are there catch-all error variants (e.g., `Unknown(String)`) that prevent exhaustive matching? Are these intentional?
- Could error variants be added later without breaking exhaustive matches in user code? (If not, this is a future-proofing concern.)
- Are errors distinct enough to be handled differently, or are there too many variants that all mean the same thing?

Ask: *"Can a user write a match/switch on your error type that will still compile after your next minor release?"*

---

# Step 6: Documentation Completeness

**Goal**: Every public item should have documentation. No exceptions for a 1.0.

Check:
- Does every public function, type, and constant have a doc comment?
- Do doc comments describe *what* the function does and *why* you'd use it, not just restate the name?
- Are there examples for non-obvious functions?
- Are panics, errors, and edge cases documented?
- Is there a top-level module/package doc that explains the library's purpose?

Ask: *"Could a user understand how to use this library using only the generated API docs, without reading source?"*

---

# Step 7: Dependency Exposure

**Goal**: Don't accidentally make your users depend on your dependencies.

Check:
- Are types from external dependencies part of your public API? (If so, adding a major version bump to that dep becomes your breaking change too.)
- Are there re-exported types from deps that users will need to import directly?
- If a dep is re-exported, is that intentional and documented?
- Could you swap out a dep without breaking user code?

Ask: *"If you replaced dependency X with an alternative tomorrow, which of your users' code would break?"*

---

# Step 8: Future-Proofing and Extensibility

**Goal**: Avoid locking yourself (and users) into decisions you'll regret.

This is the most important section for long-lived APIs.

Check:
- **Sealed vs open types**: Are record types or enums/variants fully exposed? Users pattern-matching on them means you can never add a field/variant without a breaking change.
- **Callback and interface design**: Are callbacks/interfaces narrow enough that you can add behavior later without breaking implementors?
- **Non-extensible patterns**: Any place where a user must enumerate all possibilities (exhaustive match on a public enum/variant type) is a place you can never add a case without breaking them.
- **Constructor exposure**: Public constructors mean users can create values — is that intentional? It prevents you from adding required fields later.
- **Phantom types / capabilities**: Any missing type-level constraints that would be annoying to add later?
- **Configuration and options**: Is config passed as a flat list of parameters (hard to extend) or a single options/config struct (easy to add fields)?
- **Version fields**: For serialized formats or wire protocols, is there a version field?

Ask: *"What's the most likely feature you'll add in version 1.1? Does the current API make that easy or does it require breaking changes?"*

---

# Step 9: Versioning Readiness

**Goal**: The release infrastructure should be in place before the first release.

Check:
- Is there a CHANGELOG or release notes file?
- Is there a clear versioning policy (semver, calendar versioning, etc.)?
- Is the version number in the appropriate place (`gleam.toml`, `package.json`, `Cargo.toml`, etc.) and correct?
- Are there CI checks for formatting, tests, and type-checking?
- Is there a release workflow (manual steps documented, or automated)?

---

# Step 10: Language-Specific Checks

Apply the relevant section(s) based on the library's language.

## Gleam

- [ ] Internal modules listed in `gleam.toml` under `internal_modules`
- [ ] Types that should be opaque are declared `pub opaque type`
- [ ] Public API re-exported cleanly from the top-level module
- [ ] No `@internal` types accidentally left public
- [ ] `gleam docs build` runs without errors

## TypeScript / JavaScript

- [ ] `exports` field in `package.json` controls what's importable (not just `main`)
- [ ] Internal modules are not listed in `exports`
- [ ] Types meant to be opaque use branded/nominal types or private constructors
- [ ] `@internal` JSDoc tags on items not intended for public use
- [ ] Declaration files (`.d.ts`) generated and checked for unintended exposure
- [ ] `index.ts` barrel file exports exactly the intended surface — nothing more
- [ ] No re-exported types from dependencies unless intentional

## Rust

- [ ] Internal items use `pub(crate)` or `pub(super)` rather than `pub`
- [ ] `#[doc(hidden)]` on any items that must be `pub` for macro reasons but aren't public API
- [ ] Sealed trait pattern used for traits you don't want external implementations of
- [ ] `pub use` re-exports in `lib.rs` are intentional and minimal
- [ ] Check `cargo doc` output for accidentally exposed items
- [ ] `#[non_exhaustive]` on enums and structs you might add variants/fields to

## Go

- [ ] Unexported (lowercase) identifiers for internal implementation
- [ ] Interfaces are small and focused (prefer multiple small interfaces over one large one)
- [ ] Exported struct fields are all intentionally public
- [ ] Consider whether exported types should have unexported fields with accessor methods instead
- [ ] Package names are clear and don't clash with stdlib

## OCaml

- [ ] `.mli` interface files exist for all public modules
- [ ] Internal modules not exposed in top-level `.mli`
- [ ] Abstract types (defined in `.mli` without the implementation) for opaque types
- [ ] Functors and first-class modules documented if used

## Elixir

- [ ] `@moduledoc false` on internal modules
- [ ] `@doc false` on functions that must be public (e.g., for callbacks) but aren't API
- [ ] Behaviours defined for extensible abstractions
- [ ] `:ok`/`:error` tuples consistent across the API

---

# Step 11: Present Findings

After completing all checks, summarize:

1. **Blockers** — things that will be breaking changes or embarrassments if shipped as-is
2. **Strong recommendations** — high-value changes that are easy to make now but painful later
3. **Nice-to-haves** — improvements that can wait for a future release

For each finding, state:
- What the issue is
- Why it matters (what goes wrong if ignored)
- What the fix looks like (briefly)

Then ask: *"Which of these do you want to address before releasing?"*

If the user wants to act on findings, help them make the changes. Then re-run the relevant checks to confirm they're resolved.
