---
description: Set up changie changelog management and automated release pipeline with GitHub Actions workflows.
---

# Changie Setup

Set up [changie](https://changie.dev/) for changelog management with an automated release pipeline using GitHub Actions.

## Context Discovery

First, gather context about the repository using your tools:
- Read `.changie.yaml` if it exists (existing changie config)
- Read the first 20 lines of `CHANGELOG.md` if it exists
- List `.github/workflows/` directory if it exists
- Check which project manifest files exist: `go.mod`, `Cargo.toml`, `package.json`, `pyproject.toml`, `*.cabal`
- Read `.mise.toml` if it exists
- Read `justfile` if it exists
- Get the git remote: !`git remote get-url origin 2>/dev/null`

## Your Task

Based on the context above, set up changie and the release automation pipeline.

### Step 1: Ask the User

Ask the user which components they want:

1. **Changie config** (`.changie.yaml`) - always needed
2. **Release workflow** (`release.yml`) - creates release PRs automatically on push to main
3. **Auto-tag workflow** (`auto-tag.yml`) - tags releases when release PRs merge
4. **GoReleaser** (Go projects only) - builds and publishes binaries on tag push
5. **release-plz** (Rust projects only) - creates tags and publishes to crates.io
6. **Change kinds** - which change categories to use (see defaults below)

### Step 2: Install Changie

If changie is not already available:

**Via mise (preferred if `.mise.toml` exists):**
Add `changie` to the `[tools]` section in `.mise.toml`.

**Via go install:**
```bash
go install github.com/miniscruff/changie@latest
```

**Via brew:**
```bash
brew install changie
```

### Step 3: Create `.changie.yaml`

Use `changie init` or create the config directly. The recommended config:

```yaml
changesDir: .changes
unreleasedDir: unreleased
headerPath: header.md
changelogPath: CHANGELOG.md
versionHeaderPath: ""
versionFooterPath: ""
versionExt: md
envPrefix: CHANGIE
versionFormat: '## {{.Version}} - {{.Time.Format "2006-01-02"}}'
kindFormat: '### {{.Kind}}'
changeFormat: '- {{.Body}}'
kinds:
    - label: Added
      auto: minor
    - label: Fixed
      auto: patch
    - label: Performance
      auto: patch
    - label: Changed
      auto: patch
    - label: Reverted
      auto: patch
    - label: Dependencies
      auto: patch
    - label: Security
      auto: patch
newlines:
    afterChangelogHeader: 1
    afterChangelogVersion: 1
    afterKind: 1
    afterVersion: 1
    beforeKind: 1
    endOfVersion: 1
```

Key points about kinds:
- `auto: minor` means that kind triggers a minor version bump with `changie batch auto`
- `auto: patch` triggers a patch bump
- Only one kind should be `minor` (typically "Added" for new features)
- The user may want to customize kinds for their project

### Step 4: Create Directory Structure and Header

```bash
mkdir -p .changes/unreleased
touch .changes/.gitkeep
touch .changes/unreleased/.gitkeep
```

**CRITICAL: Create a header file** at `.changes/header.md`. This is the preamble that `changie merge` places at the top of CHANGELOG.md. Without it, `changie merge` will overwrite the entire CHANGELOG with only version entries and no header.

Example `.changes/header.md`:
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
```

### Step 5: Migrate Existing Version History

**CRITICAL: If the project has existing releases, you MUST create version files for all historical versions.** Without them, `changie latest` returns `v0.0.0` and the next `changie batch auto` will compute the version bump from 0.0.0 instead of the actual current version (e.g., producing `v0.1.0` instead of `v2.4.1`).

**How changie tracks versions:** Changie determines the current version by scanning `.changes/` for version files (e.g., `.changes/v1.2.3.md`). If none exist, it assumes `v0.0.0`. The `changie merge` command regenerates CHANGELOG.md entirely from these version files plus the header — it does NOT preserve any content already in CHANGELOG.md that doesn't come from a version file.

**Migration steps:**

1. Parse the existing CHANGELOG.md to extract each version's content
2. Create a `.changes/vX.Y.Z.md` file for each historical version
3. Each file should use changie's version header format: `## vX.Y.Z - YYYY-MM-DD`
4. Preserve all section content (### Added, ### Fixed, etc.) as-is
5. Run `changie merge` and verify the output matches expectations

**Example migration script** (adapt the header regex to match your CHANGELOG format):

```python
import re

with open('CHANGELOG.md') as f:
    content = f.read()

pattern = r'^## \[?(\d+\.\d+\.\d+)\]?(?:\([^)]*\))?\s*-\s*(\d{4}-\d{2}-\d{2})'
parts = re.split(r'(?=^## \[?\d+\.\d+\.\d+)', content, flags=re.MULTILINE)

for part in parts:
    match = re.match(pattern, part, re.MULTILINE)
    if not match:
        continue
    version, date = match.group(1), match.group(2)
    body = re.sub(pattern, f'## v{version} - {date}', part, count=1, flags=re.MULTILINE)
    with open(f'.changes/v{version}.md', 'w') as f:
        f.write(body.rstrip() + '\n')
```

**If there is no existing CHANGELOG** (fresh project), skip this step.

**If there is an existing CHANGELOG but you don't want to migrate all history**, at minimum create a version file for the current version so `changie latest` returns the correct value:

```bash
changie batch v<CURRENT_VERSION> --allow-no-changes
```

### Step 6: Create GitHub Actions Workflows

#### Release workflow (`.github/workflows/release.yml`)

Creates a release PR automatically whenever changes are pushed to main and unreleased change fragments exist.

```yaml
name: Release

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - uses: tylerbutler/actions/changie-release@main
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Summary
        if: steps.release.outputs.skipped != 'true'
        env:
          VERSION: ${{ steps.release.outputs.version }}
          PR_URL: ${{ steps.release.outputs.pr-url }}
          PR_OP: ${{ steps.release.outputs.pr-operation }}
        run: |
          echo "### Release PR Created" >> "$GITHUB_STEP_SUMMARY"
          echo "" >> "$GITHUB_STEP_SUMMARY"
          echo "- **Version:** $VERSION" >> "$GITHUB_STEP_SUMMARY"
          echo "- **PR:** $PR_URL" >> "$GITHUB_STEP_SUMMARY"
          echo "- **Operation:** $PR_OP" >> "$GITHUB_STEP_SUMMARY"

      - name: Skipped
        if: steps.release.outputs.skipped == 'true'
        run: |
          echo "### Release Skipped" >> "$GITHUB_STEP_SUMMARY"
          echo "" >> "$GITHUB_STEP_SUMMARY"
          echo "No unreleased change fragments found." >> "$GITHUB_STEP_SUMMARY"
```

**changie-release action inputs** (all optional with sensible defaults):
- `version`: `auto` (default), `major`, `minor`, `patch`, or explicit semver
- `skip-if-no-changes`: `true` (default) - skip gracefully when no fragments exist
- `pr-title-template`: `Release {version}` - supports `{version}` placeholder
- `branch-template`: `release/{version}` - supports `{version}` placeholder
- `commit-message-template`: `chore(release): {version}` - supports `{version}` placeholder
- `pr-body-template`: `{changelog}` - supports `{version}` and `{changelog}` placeholders
- `labels`: `release` - comma-separated labels for the PR
- `draft`: `false` - create as draft PR
- `delete-branch`: `true` - delete branch after merge

#### Auto-tag workflow (`.github/workflows/auto-tag.yml`)

Creates a git tag when a release PR (labeled `release`) is merged.

```yaml
name: Auto-tag release

on:
  pull_request:
    types: [closed]
    branches: [main]

permissions:
  contents: write

jobs:
  tag:
    if: github.event.pull_request.merged && contains(github.event.pull_request.labels.*.name, 'release')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - uses: tylerbutler/actions/changie-auto-tag@main
```

**changie-auto-tag action inputs** (all optional):
- `tag-prefix`: empty by default. `changie latest` already returns versions with `v` prefix (e.g. `v0.1.0`). Only set this for monorepo/multi-package repos that need package-scoped tags (e.g. `mypackage/`)
- `working-directory`: `.` - directory containing `.changie.yaml`

### Step 7 (Go projects only): GoReleaser

If this is a Go project and the user wants binary releases:

#### `.goreleaser.yaml`

Adapt the project name, binary name, and GitHub owner/repo:

```yaml
version: 2

project_name: PROJECT_NAME

before:
  hooks:
    - go mod tidy

builds:
  - binary: PROJECT_NAME
    env:
      - CGO_ENABLED=0
    goos:
      - linux
      - darwin
      - windows
    goarch:
      - amd64
      - arm64
    ldflags:
      - -s -w -X main.version={{.Version}} -X main.commit={{.Commit}} -X main.date={{.Date}}

archives:
  - formats:
      - tar.gz
    format_overrides:
      - goos: windows
        formats:
          - zip
    name_template: >-
      {{ .ProjectName }}_{{ .Version }}_{{ .Os }}_{{ .Arch }}

changelog:
  disable: false
  use: ""
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
      - "^ci:"
      - "^chore:"
  groups:
    - title: Features
      regexp: '^.*?feat(\([[:word:]]+\))??!?:.+$'
      order: 0
    - title: Bug Fixes
      regexp: '^.*?fix(\([[:word:]]+\))??!?:.+$'
      order: 1
    - title: Performance
      regexp: '^.*?perf(\([[:word:]]+\))??!?:.+$'
      order: 2
    - title: Other
      order: 999

checksum:
  name_template: checksums.txt

release:
  github:
    owner: GITHUB_OWNER
    name: GITHUB_REPO
  header: |
    ## Changelog

    {{ .Env.CHANGIE_CHANGELOG }}
  footer: |
    **Full Changelog**: https://github.com/GITHUB_OWNER/GITHUB_REPO/compare/{{ .PreviousTag }}...{{ .Tag }}
```

#### GoReleaser workflow (`.github/workflows/goreleaser.yml`)

Adapt the setup step to the project's language:

```yaml
name: GoReleaser

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - uses: actions/setup-go@v6
        with:
          go-version-file: go.mod

      - uses: miniscruff/changie-action@v2.0.0

      - name: Get changelog for version
        id: changelog
        run: |
          version=$(changie latest)
          echo "CHANGIE_CHANGELOG<<EOF" >> "$GITHUB_ENV"
          cat ".changes/${version}.md" >> "$GITHUB_ENV"
          echo "EOF" >> "$GITHUB_ENV"

      - uses: goreleaser/goreleaser-action@v6
        with:
          version: '~> v2'
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          CHANGIE_CHANGELOG: ${{ env.CHANGIE_CHANGELOG }}
```

### Step 8 (Rust projects only): release-plz

If this is a Rust project (`Cargo.toml` exists) and the user wants automated crate publishing and tagging:

**How it works with changie:** release-plz handles only the `release` command (tagging + crate publishing). Changie owns changelog management and version determination. The release workflow bumps `Cargo.toml` to match changie's version, and release-plz creates the git tag + publishes to crates.io when the release PR merges.

#### `release-plz.toml`

Disable release-plz features that changie now handles:

```toml
[workspace]
# Changelog is managed by changie, not release-plz
changelog_update = false

# PR creation is handled by changie-release workflow
pr_enabled = false

# Disable GitHub release creation - cargo-dist handles this with binary assets
git_release_enable = false
# Enable git tag creation - this triggers cargo-dist release workflow
git_tag_enable = true
git_tag_name = "v{{ version }}"
```

Key points:
- `changelog_update = false` - changie manages the CHANGELOG, not release-plz
- `pr_enabled = false` - the changie-release workflow creates release PRs
- `git_tag_enable = true` - release-plz creates the tag that triggers cargo-dist
- If not using cargo-dist, set `git_release_enable = true` to have release-plz create GitHub releases

#### release-plz workflow (`.github/workflows/release-plz.yml`)

Runs on push to main. Only uses the `release` command (not `release-pr`):

```yaml
name: Release-plz

permissions:
  contents: write

on:
  push:
    branches:
      - main

jobs:
  release-plz-release:
    name: Release-plz release
    runs-on: ubuntu-latest
    concurrency:
      group: release-plz-release
      cancel-in-progress: false

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          fetch-depth: 0
          persist-credentials: false

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Run release-plz release
        uses: release-plz/action@v0.5
        with:
          command: release
        env:
          GITHUB_TOKEN: ${{ secrets.RELEASE_PLZ_TOKEN }}
          CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

**Required secrets:**
- `RELEASE_PLZ_TOKEN` - GitHub PAT with `contents: write` permission (needed to create tags that trigger other workflows; `GITHUB_TOKEN` won't trigger downstream workflows)
- `CARGO_REGISTRY_TOKEN` - crates.io API token for publishing

#### Version bump in changie-release workflow

When using release-plz, add a Cargo.toml version bump step to the changie-release workflow so the version in `Cargo.toml` stays in sync:

```yaml
      # After the changie-release step:
      - name: Bump Cargo.toml version
        if: steps.release.outputs.skipped != 'true'
        env:
          VERSION: ${{ steps.release.outputs.version }}
          PR_BRANCH: ${{ steps.release.outputs.pr-branch }}
        run: |
          SEMVER="${VERSION#v}"
          sed -i "s/^version = \".*\"/version = \"${SEMVER}\"/" Cargo.toml
          cargo generate-lockfile

          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git checkout "$PR_BRANCH"
          git add Cargo.toml Cargo.lock
          if ! git diff --cached --quiet; then
            git commit -m "chore: bump version to ${SEMVER}"
            git push origin "$PR_BRANCH"
          fi
```

#### Pipeline flow with release-plz + cargo-dist

```
changie-release creates PR (bumps Cargo.toml + CHANGELOG)
         |
         v
Developer merges release PR
         |
         v
release-plz detects version change in Cargo.toml
  - Creates git tag (e.g. v0.6.0)
  - Publishes to crates.io
         |
         v
cargo-dist release workflow (triggered by tag)
  - Builds platform binaries
  - Creates GitHub release with assets
```

### Step 9: Update Justfile (if exists)

If a justfile exists, add changie-related recipes:

```just
# Create a new changelog entry
change:
    changie new

# Preview the next version changelog
changelog-preview:
    changie batch auto --dry-run
```

### Step 10: Create Initial Change Fragment (optional)

If this is a first release, ask if the user wants to create an initial change fragment:

```bash
changie new --kind Added --body "Initial release" --custom ""
```

### Step 11: Add to .gitignore (if needed)

No changie-specific entries are needed in `.gitignore` - all changie files should be committed.

### Step 11: Verify Setup

**Always run these verification checks after setup:**

```bash
# Should return the current version (NOT v0.0.0)
changie latest

# Should return correct next versions
changie next minor
changie next patch

# Should produce the complete CHANGELOG with header and all versions
changie merge --dry-run
```

**If `changie latest` returns `v0.0.0`**, you missed Step 5 (migrating version history). Go back and create version files for existing releases.

**If `changie merge --dry-run` is missing the CHANGELOG header**, check that `.changes/header.md` exists and `headerPath: header.md` is set in `.changie.yaml`.

**If `changie merge --dry-run` is missing historical versions**, create `.changes/vX.Y.Z.md` files for each missing version.

## Gotchas

- **`changie latest` returns `v0.0.0` if no version files exist in `.changes/`.** This is the most common setup mistake — if you're adding changie to a project with existing releases, you MUST create version files for all historical versions (or at minimum the current version). Without them, `changie batch auto` computes the next version from 0.0.0.
- **`changie merge` overwrites the entire CHANGELOG.md.** It regenerates the file from the header file + version files only. Any content in CHANGELOG.md that doesn't come from `.changes/` will be lost. This is why you need both `headerPath` pointing to a header file AND version files for all releases.
- `changie latest` returns versions WITH `v` prefix (e.g. `v0.1.0`)
- `changie batch auto` exits non-zero when no unreleased fragments exist - the changie-release action handles this gracefully with `skip-if-no-changes: true`
- Unreleased fragments are `.yaml` files in `.changes/unreleased/`
- The `release` label on PRs is required for `auto-tag.yml` to trigger - the changie-release action adds this label automatically
- The full pipeline flow is: push to main -> release.yml creates PR -> merge PR -> auto-tag.yml creates tag -> goreleaser.yml builds release

## Pipeline Flows

### Go projects (with GoReleaser)

```
Developer pushes to main
         |
         v
  release.yml (on push)
  - Checks for unreleased .yaml fragments
  - If none: skips gracefully
  - If found: changie batch + merge, create/update release PR with "release" label
         |
         v
  Developer reviews & merges release PR
         |
         v
  auto-tag.yml (on PR close)
  - Checks PR has "release" label and was merged
  - Runs changie latest to get version
  - Creates and pushes git tag (e.g. v0.1.0)
         |
         v
  goreleaser.yml (on tag push matching v*)
  - Builds binaries for all platforms
  - Creates GitHub release with changie changelog
```

### Rust projects (with release-plz + cargo-dist)

```
Developer pushes to main
         |
         v
  changie-release.yml (on push)
  - Checks for unreleased .yaml fragments
  - If none: skips gracefully
  - If found: changie batch + merge, bump Cargo.toml version,
    create/update release PR with "release" label
         |
         v
  Developer reviews & merges release PR
         |
         v
  release-plz.yml (on push to main)
  - Detects version change in Cargo.toml
  - Creates git tag (e.g. v0.6.0)
  - Publishes crate to crates.io
         |
         v
  release.yml / cargo-dist (on tag push matching v*)
  - Builds platform binaries
  - Creates GitHub release with binary assets
  - Updates Homebrew tap
```
