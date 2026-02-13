# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository managed by [chezmoi](https://www.chezmoi.io/), a cross-platform dotfile manager. The repository contains configuration files, shell scripts, and templates for setting up development environments across Linux, macOS, Windows, and WSL.

## Chezmoi Architecture

### File Naming Conventions

Chezmoi uses special prefixes to determine how files are processed:

- `dot_` → Files starting with `.` (e.g., `dot_bashrc` → `~/.bashrc`)
- `private_` → Files with restricted permissions (chmod 600)
- `executable_` → Files that should be executable (chmod +x)
- `symlink_` → Files that should be symlinked rather than copied
- `.tmpl` suffix → Template files processed with Go templates
- `run_once_` → Scripts that run once on `chezmoi apply`
- `run_onchange_` → Scripts that run when the file content changes

### Directory Structure

- **Root dotfiles** (`dot_*`): Standard dotfiles like `.bashrc`, `.zshrc`, `.gitconfig`
- **dot_aliae.yaml**: Shell aliases managed by [aliae](https://github.com/JanDeDobbeleer/aliae) with cross-platform templating (`{{ .Home }}`)
- **dot_config/**: XDG config directory (`~/.config`) — app configs for mise, git, gh, ghostty, atuin, etc.
- **dot_claude/**: Global Claude Code config (`~/.claude/`) — `commands/`, `skills/`, `settings.json`
- **.claude/**: Repo-local Claude Code config — `skills/`, `agents/`, `settings.json` (hooks)
- **dot_claude-mem/**: Claude memory worker configuration
- **Brewfile**: Homebrew dependencies (macOS), applied via `run_onchange_install-brewfile.sh.tmpl`
- **_scripts/**: Chezmoi run scripts for system setup
  - `_scripts/01/`: First-run installation scripts (package managers, dependencies)
  - `run_once_*`: One-time setup scripts
  - `run_onchange_*`: Scripts that run when their content changes
- **_sources/**: Source files that don't map directly to home directory
- **private_AppData/**, **private_Library/**: Windows and macOS platform-specific configs
- **private_dot_local/bin/**: Install scripts (templated, platform-conditional)
- **.chezmoiignore**: Conditional ignore rules (OS-specific, rbw-dependent)
- **.chezmoitemplates/**: Shared reusable templates (lsd, rbw)

## Common Operations

### Testing Changes
```bash
# See what would be applied without making changes
chezmoi apply --dry-run --verbose

# See diff of changes
chezmoi diff
```

### Making Changes
```bash
# Edit a file in chezmoi source directory
chezmoi edit ~/.bashrc

# Apply changes to home directory
chezmoi apply

# Add an existing file to chezmoi
chezmoi add ~/.newconfig
```

### Working with Templates
```bash
chezmoi execute-template < file.tmpl    # Preview template output
chezmoi execute-template '{{ .chezmoi.os }}'  # Test syntax
chezmoi data                            # View available template data
chezmoi chattr +template <file>         # Convert file to template
```

## Configuration System

### Encryption
- Uses **age** encryption for sensitive files
- Private key: `~/age-key.txt`
- Password manager: **rbw** (Bitwarden CLI) — **disabled by default**
- Enable with: `CHEZMOI_USE_RBW=true chezmoi apply`
- Without rbw, SSH keys and age-key.txt are skipped via `.chezmoiignore`

### Template Variables
- Standard: `.chezmoi.os`, `.chezmoi.arch`, `.chezmoi.homeDir`, `.chezmoi.sourceDir`
- Custom (from `.chezmoi.toml.tmpl`): `.name`, `.email`, `.codespaces`, `.use_rbw`
- Run `chezmoi data` to see all available variables
- Go template syntax with [Sprig functions](http://masterminds.github.io/sprig/)
- Shared templates in `.chezmoitemplates/`, included via `{{ template "name.tmpl" . }}`

### Platform-Specific Patterns
- `.chezmoiignore`: Conditional file exclusion based on OS and tool availability
- Git configs: `dot_config/git/*.gitconfig` with includeIf directives
- Platform detection: `$SYSTEM_TYPE` variable (Darwin, Linux, Windows)
- Aliae templates: `{{ .Home }}`, `{{ .OS }}` for cross-platform aliases

## Special Configurations

### Shell Setup
- Primary shell: **zsh** with Headline theme prompt
- Plugin manager: **Zgenom** (auto-updates weekly)
- Fallback: bash with similar configuration
- SSH sessions: Auto-attach to Zellij terminal multiplexer

### Git Configuration
- Main branch: `main`
- Diff tool: `difftastic` with delta pager
- Editor: `micro`
- Conditional user configs based on remote URL:
  - Personal repos (`tylerbutler/*`): Personal email
  - Work repos (`microsoft/*`): Work email
- Git aliases available in `dot_gitconfig` (e.g., `dm` for deleting merged branches)

### Package Management
- `Brewfile` - Homebrew (macOS), auto-installed via `run_onchange_` script
- `dot_config/mise/config.toml` - Dev tools via [mise](https://mise.jdx.dev/) (runtime manager)
- `dot_default-apt` - APT packages (Ubuntu/Debian)
- `dot_default-cargo-crates` - Rust crates
- `dot_default-eget` - Binary downloads via eget
- `dot_default-nix-packages` - Nix packages
- `dot_default-pacman-packages` - Arch packages
- `dot_default-chocolatey-packages.config` - Windows packages
- `dot_default-scoop-packages` - Windows Scoop packages

### Alias Management (aliae)
- Aliases defined in `dot_aliae.yaml`, managed by [aliae](https://github.com/JanDeDobbeleer/aliae)
- Initialized in `.zshrc` via `eval "$(aliae init zsh)"`
- Alias values support Go-style templates: `{{ .Home }}`, `{{ .OS }}`, `{{ if eq .OS "darwin" }}...{{ end }}`
- Prefer adding new aliases to `dot_aliae.yaml` rather than shell rc files

### Claude Code Integration
- Global config (`dot_claude/` → `~/.claude/`): commands, skills, plugins, settings
- Repo-local config (`.claude/`): project-specific skills, agents, hooks

## File Operations Notes

- **DO NOT** use `mv` or `cp` commands - they prompt for confirmation in this environment
- **USE** `rm -f` to delete files without prompts
- When editing files, use `chezmoi edit` or edit in source directory, then `chezmoi apply`

## Important Conventions

1. **Always test changes**: Use `chezmoi diff` or `chezmoi apply --dry-run` before applying
2. **Template syntax**: Use Go template syntax in `.tmpl` files
3. **Cross-platform**: Consider OS-specific logic in templates
4. **Encryption**: Use chezmoi's encryption for sensitive data, not plain text
5. **Scripts**: Place one-time setup scripts in `_scripts/` with proper `run_once_` prefix
6. **Aliases**: Add new aliases to `dot_aliae.yaml`, not shell rc files
