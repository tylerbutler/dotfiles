---
name: ccl-test-data-just
description: Configures a `download-tests` justfile recipe that fetches ccl-test-data JSON test fixtures from GitHub releases via `npx -y ccl-test-runner-ts`. Use this whenever the user wants to set up, add, fix, standardize, or update the test-data download task in a CCL implementation repository (ccl-c, ccl-haskell, ccl-java, ccl-kotlin, ccl-scala, ccl-dotnet, ccl_gleam, ccl-typescript, ccl_test_runner_ocaml, or any new CCL implementation) — including requests phrased as "wire up test data", "add a justfile recipe to download ccl-test-data", "fix the test-data download", or any case where you notice an existing `update-test-data` / `download-tests` recipe using the buggy `-o=./...` form.
---

# CCL Test Data — `just download-tests`

## What this skill is for

Across the CCL workspace (`ccl-test-data`, `ccl-c`, `ccl-haskell`, `ccl-java`, `ccl-kotlin`, `ccl-scala`, `ccl-dotnet`, `ccl_gleam`, `ccl-typescript`, `ccl_test_runner_ocaml`, …), every implementation needs the same JSON test suite checked out into a local `ccl-test-data/` directory before tests can run. The shared way to do that is the `ccl-test-runner-ts` npm package, invoked from a justfile recipe.

This skill establishes a single canonical recipe so every repo looks the same. New repos get it wired up correctly the first time; older repos get migrated off the buggy `-o=./...` form.

## The canonical recipe

Add this to the repo's top-level `justfile`:

```just
# Download CCL test data from GitHub releases into ./ccl-test-data
download-tests:
    npx -y ccl-test-runner-ts -o ./ccl-test-data
```

Three things matter here and should not drift:

1. **`npx -y`** — the `-y` auto-accepts the npx package install prompt. Without it, fresh machines and CI hang waiting for stdin.
2. **`-o ./ccl-test-data`** with a *space*, not `-o=./ccl-test-data`. The CLI's argument parser treats the `=`-form as a literal path, which silently creates a directory named `=` (or `=./ccl-test-data`) and leaves the real `ccl-test-data/` empty. If you see that bug in an existing recipe, fix it.
3. **Recipe name `download-tests`** — singular standard across the workspace. If a repo has a recipe named `update-test-data`, `update_test_data`, `fetch-tests`, etc., rename it to `download-tests` (and update any `deps:` line that references it).

## Flag support — what to expose

The underlying CLI supports more than the basic case. When the user asks for any of these, add the corresponding recipe (don't bake flags into the default recipe — keep the no-arg form simple):

| User intent | Recipe to add |
|---|---|
| Pin to a specific test-data release tag | `download-tests-version VERSION:` calling `npx -y ccl-test-runner-ts -o ./ccl-test-data --version {{VERSION}}` |
| Force-refresh, ignoring up-to-date check | `download-tests-force:` calling `npx -y ccl-test-runner-ts -o ./ccl-test-data --force` |
| Pull the very latest release, ignoring any `.version` pin | `download-tests-latest:` calling `npx -y ccl-test-runner-ts -o ./ccl-test-data --latest` |

Use `--version` and `--latest` only when the user explicitly asks. They are mutually exclusive and most repos should default to the plain `download-tests` (which honors any pinned `.version` file the test runner CLI supports).

## Wiring into `deps`

If the repo has a `deps:` recipe that installs language dependencies, the test data should be fetched alongside them so a fresh clone can run tests in one command. Add `download-tests` as a prerequisite:

```just
deps: download-tests
    # ... existing language-specific install steps ...
```

If the repo has no `deps:` recipe, don't invent one — leave `download-tests` standalone. Different repos have different conventions and creating a `deps:` purely to host this dependency is overreach.

## Output directory placement

The data should land wherever the consuming test runner reads it from — that's the only thing that matters. Don't impose a layout on the repo.

For a flat repo (most CCL implementations), `./ccl-test-data` at the repo root is the natural fit, and the recipe is just:

```just
download-tests:
    npx -y ccl-test-runner-ts -o ./ccl-test-data
```

For a monorepo where the test runner lives in a sub-package and reads from a relative path, `cd` into that package first so `-o ./ccl-test-data` resolves to where the runner expects it. For example, `ccl_gleam` keeps the runner under `packages/ccl_test_runner/` and looks for `./ccl-test-data` from there:

```just
runner_dir := "packages/ccl_test_runner"

download-tests:
    cd {{ runner_dir }} && npx -y ccl-test-runner-ts -o ./ccl-test-data
```

When deciding placement: read the test runner's source first to see where it expects the data, and match that. Don't restructure the repo to satisfy a "canonical" layout.

## .gitignore

The downloaded `ccl-test-data/` directory must not be committed. Verify the repo's `.gitignore` excludes it; if not, add a line matching the actual download path:

```
ccl-test-data/                          # flat repo
packages/ccl_test_runner/ccl-test-data/ # monorepo, adjust to the runner package's path
```

Skip this only if the repo already has a broader rule that covers it.

## When migrating an existing recipe

When an older repo already has a download recipe under a different name or with the bug, the migration is:

1. Rename the recipe to `download-tests`.
2. Replace `-o=./ccl-test-data` with `-o ./ccl-test-data`.
3. Add `-y` after `npx` if missing.
4. Update any `deps:` line that referenced the old recipe name.
5. If a stray `=` directory exists from the old buggy run, delete it (`rm -rf './='` — note the quoting; the `=` is a literal directory name).
6. Run `just download-tests` once to verify the fix produces real data in `./ccl-test-data/`.

## Why these choices

- **One recipe name everywhere** lets cross-repo automation (`mani`, the workspace `justfile`, CI templates) target `just download-tests` without per-repo conditionals.
- **`npx -y` over a checked-in script** keeps each repo lightweight: no Node lockfile, no committed download tooling, just one line that always pulls the current published version of `ccl-test-runner-ts`.
- **Space-separated `-o`** is the form the CLI's argument parser actually handles correctly. The `=`-form failure is silent (no error, wrong directory created) which is exactly the kind of bug worth designing out at the recipe level.
