---
name: chezmoi-workflow
description: Guide for working with chezmoi dotfiles - file naming, templates, and apply workflow. Use when editing files in this dotfiles repository.
user-invocable: false
---

# Chezmoi Workflow Guide

When editing files in this repository, follow these rules:

## File Creation

New dotfiles must use chezmoi prefixes:

| Prefix | Effect | Example |
|--------|--------|---------|
| `dot_` | Adds leading `.` | `dot_bashrc` -> `~/.bashrc` |
| `private_` | chmod 600 | `private_dot_ssh` -> `~/.ssh` (restricted) |
| `executable_` | chmod +x | `executable_script.sh` -> `script.sh` (executable) |
| `symlink_` | Creates symlink | `symlink_dotfile` -> symlink to target |
| `.tmpl` suffix | Go template processing | `dot_bashrc.tmpl` -> `~/.bashrc` (templated) |
| `run_once_` | One-time script | Runs once on `chezmoi apply` |
| `run_onchange_` | Change-triggered script | Runs when content hash changes |

Prefixes can be combined: `private_dot_config` -> `~/.config` with restricted permissions.

## Template Variables

Available in `.tmpl` files (verify with `chezmoi data`):

| Variable | Value |
|----------|-------|
| `{{ .chezmoi.os }}` | linux, darwin, windows |
| `{{ .chezmoi.arch }}` | amd64, arm64 |
| `{{ .chezmoi.homeDir }}` | Home directory path |
| `{{ .chezmoi.sourceDir }}` | Source directory path |
| `{{ .name }}` | "Tyler Butler" |
| `{{ .email }}` | "tyler@tylerbutler.com" |
| `{{ .codespaces }}` | Boolean for GitHub Codespaces |
| `{{ .use_rbw }}` | Boolean for Bitwarden availability |

Template functions: All Go template functions plus [Sprig functions](http://masterminds.github.io/sprig/).

Shared templates: `.chezmoitemplates/` directory, include via `{{ template "name.tmpl" . }}`.

## Aliases

Add new aliases to `dot_aliae.yaml`, NOT to shell rc files.

Use aliae template syntax for cross-platform values:
- `{{ .Home }}` instead of `~` or `$HOME`
- `{{ .OS }}` for OS detection
- `{{ if eq .OS "darwin" }}mac-command{{ else }}linux-command{{ end }}` for conditionals

## Validation

After any change, verify before applying:

1. `chezmoi diff` - preview what would change
2. `chezmoi apply --dry-run --verbose` - test full apply
3. For templates: `chezmoi execute-template < file.tmpl`

## Package Lists

Add new packages to the correct platform-specific file:

| File | Platform |
|------|----------|
| `Brewfile` | macOS (Homebrew) |
| `dot_default-apt` | Ubuntu/Debian |
| `dot_default-cargo-crates` | Rust (cross-platform) |
| `dot_default-eget` | Binary downloads (cross-platform) |
| `dot_default-nix-packages` | NixOS |
| `dot_default-pacman-packages` | Arch Linux |
| `dot_default-chocolatey-packages.config` | Windows |
| `dot_default-scoop-packages` | Windows (Scoop) |

## Conditional Ignores

Use `.chezmoiignore` for OS-specific file exclusion:

```
{{ if ne .chezmoi.os "darwin" }}
Brewfile
{{ end }}
```

## DO NOT

- Edit files directly in `~/` (they'll be overwritten by `chezmoi apply`)
- Use `mv` or `cp` commands (they prompt for confirmation in this environment)
- Commit secrets in plain text (use age encryption)
- Add aliases to shell rc files (use `dot_aliae.yaml` instead)
