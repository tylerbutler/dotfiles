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
5. **Change kinds** - which change categories to use (see defaults below)

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
headerPath: ""
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

### Step 4: Create Directory Structure

```bash
mkdir -p .changes/unreleased
touch .changes/.gitkeep
touch .changes/unreleased/.gitkeep
```

### Step 5: Create GitHub Actions Workflows

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

### Step 6 (Go projects only): GoReleaser

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

### Step 7: Update Justfile (if exists)

If a justfile exists, add changie-related recipes:

```just
# Create a new changelog entry
change:
    changie new

# Preview the next version changelog
changelog-preview:
    changie batch auto --dry-run
```

### Step 8: Create Initial Change Fragment (optional)

If this is a first release, ask if the user wants to create an initial change fragment:

```bash
changie new --kind Added --body "Initial release" --custom ""
```

### Step 9: Add to .gitignore (if needed)

No changie-specific entries are needed in `.gitignore` - all changie files should be committed.

## Gotchas

- `changie latest` returns versions WITH `v` prefix (e.g. `v0.1.0`)
- `changie batch auto` exits non-zero when no unreleased fragments exist - the changie-release action handles this gracefully with `skip-if-no-changes: true`
- Unreleased fragments are `.yaml` files in `.changes/unreleased/`
- The `release` label on PRs is required for `auto-tag.yml` to trigger - the changie-release action adds this label automatically
- The full pipeline flow is: push to main -> release.yml creates PR -> merge PR -> auto-tag.yml creates tag -> goreleaser.yml builds release

## Pipeline Flow

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
