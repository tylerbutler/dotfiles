---
name: justfile-creator
description: Use when creating, editing, or reviewing justfiles for any project. Use when user asks to add a justfile, set up task runner commands, or standardize project recipes. Triggers on "justfile", "just", "task runner", "project recipes".
---

# Justfile Creator

Justfiles are **task runners, not shell scripts**. Each recipe is a simple command invocation. No shell scripting constructs.

## Required Structure

Every justfile MUST follow this exact structure:

```just
# Brief project description

# === ALIASES ===
alias b := build
alias t := test
alias f := format
alias l := lint
alias c := clean

# Default recipe
default:
    @just --list

# === STANDARD RECIPES ===

# Compile the project
build:
    <single command>

# Run tests
test:
    <single command>

# Format code
format:
    <single command>

# Run linter
lint:
    <single command>

# Remove build artifacts
clean:
    <single command>

# Full validation workflow
ci: format lint test build

alias pr := ci
```

## Required Recipes

ALL six are mandatory. No exceptions, no renaming.

| Recipe | Purpose | Alias | Common Mistake |
|--------|---------|-------|----------------|
| `build` | Compile/build | `b` | - |
| `test` | Run tests | `t` | - |
| `format` | Format code | `f` | Using `fmt` instead |
| `lint` | Run linter | `l` | - |
| `clean` | Remove artifacts | `c` | Adding shell logic |
| `ci` | Full workflow | `pr` | Missing or renamed |

**The recipe MUST be named `format`, not `fmt`.** Language conventions (Go's `gofmt`, Rust's `cargo fmt`) do NOT override this.

**`alias pr := ci` is REQUIRED.** It goes after the `ci` recipe definition (not at the top with the other aliases, since `ci` isn't defined yet at that point). Don't forget it.

## Optional Recipes

Only add these if the user specifically asks or the project clearly needs them:

| Recipe | Purpose |
|--------|---------|
| `check` | Validation without building (type checks, format checks) |
| `deps` | Install dependencies |

## Rules

### Each recipe = one command

```just
# CORRECT
build:
    go build ./cmd/...

# CORRECT - multiple independent cleanup lines are OK
clean:
    rm -rf build
    rm -rf dist
```

### NO shell scripting

```just
# WRONG - conditional
run:
    if [ -f config.json ]; then go build; fi

# WRONG - pipe
info:
    cargo metadata | jq '.packages'

# WRONG - fallback
version:
    git describe --tags || echo "dev"

# WRONG - loop
build:
    for pkg in a b c; do go build $pkg; done

# WRONG - redirection
test:
    go test ./... 2>/dev/null

# WRONG - command chaining
clean:
    rm -rf ./bin/ && rm -f test.log

# CORRECT - separate lines instead of &&
clean:
    rm -rf ./bin/
    rm -f test.log
```

### NO variables

Inline values directly. Exception: `set` and `export` directives for configuration only when necessary.

```just
# WRONG
bin_dir := "./bin"
build:
    go build -o {{bin_dir}} ./cmd/...

# CORRECT
build:
    go build -o ./bin/ ./cmd/...
```

### NO over-engineering

Only include the 6 required recipes plus `check` and `deps` if needed. Do NOT add:
- `watch` recipes
- `test-coverage` or `test-verbose`
- `run` or `dev` recipes
- `docs` or `audit` recipes
- `build-release` or mode variants
- `pre-commit` recipes
- Parameterized recipes (`build-pkg package:`)
- `help` as a separate recipe (default handles this)

If the user asks for additional recipes beyond the standard set, add them. But never speculatively add extras.

### Aliases go at the TOP

```just
# === ALIASES ===
alias b := build
alias t := test
alias f := format
alias l := lint
alias c := clean
# ci alias goes after ci recipe definition
```

The `pr` alias for `ci` goes after the `ci` recipe since `ci` is defined last.

### Default recipe

Always exactly:
```just
default:
    @just --list
```

Never create a separate `help` recipe. Never use `default: help`.

### Private recipes

Use underscore prefix for internal helpers:
```just
_setup:
    <internal command>

build: _setup
    go build ./...
```

### Cross-platform

- No bash-specific syntax
- No Unix-only commands without Windows equivalents
- Use tool CLIs over shell built-ins
- Use `set windows-shell` if PowerShell compatibility is needed

## Quick Reference by Language

### Go
```just
build:
    go build ./cmd/...
test:
    go test ./...
format:
    gofumpt -w .
lint:
    golangci-lint run
clean:
    rm -rf ./bin/
```

### Rust
```just
build:
    cargo build
test:
    cargo test
format:
    cargo fmt
lint:
    cargo clippy -- -D warnings
clean:
    cargo clean
```

### TypeScript (pnpm)
```just
build:
    pnpm build
test:
    pnpm test
format:
    pnpm run format
lint:
    pnpm run lint
clean:
    rm -rf node_modules dist
```

### Python
```just
build:
    python -m build
test:
    pytest
format:
    ruff format .
lint:
    ruff check .
clean:
    rm -rf dist build *.egg-info
```

## Sections (Large Files Only)

If file grows beyond the standard recipes, use section headers:
```just
# === SECTION NAME ===
```

Common sections: `ALIASES`, `BUILD`, `TESTING`, `QUALITY`, `RELEASE`, `UTILITIES`

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Named recipe `fmt` | Rename to `format` |
| Added 10+ extra recipes | Remove all non-required recipes unless user asked |
| Used `default: help` | Use `default:` with `@just --list` directly |
| Added shell pipes/conditionals | One simple command per recipe |
| Used variables | Inline the values |
| No aliases | Add all 6 standard aliases at top of file |
| Missing `ci` recipe | Add `ci: format lint test build` with `alias pr := ci` |
| Added `set dotenv-load` | Only add directives when actually needed |
