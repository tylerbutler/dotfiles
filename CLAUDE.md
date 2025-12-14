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
- **dot_config/**: XDG config directory (`~/.config`) containing app-specific configs
- **dot_claude/**: Claude Code configuration with custom commands, agents, and framework docs
- **_scripts/**: Chezmoi run scripts for system setup
  - `_scripts/01/`: First-run installation scripts (package managers, dependencies)
  - `run_once_*`: One-time setup scripts
  - `run_onchange_*`: Scripts that run when their content changes
- **_sources/**: Source files that don't map directly to home directory
- **private_*/**: Platform-specific private configurations (Windows, macOS)

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
# Execute a template to see output
chezmoi execute-template < file.tmpl

# Test template syntax directly
chezmoi execute-template '{{ .chezmoi.os }}'

# View template data available
chezmoi data

# Convert existing file to template
chezmoi chattr +template ~/.config/someapp/config.yml
```

### Git Operations
```bash
# Changes are auto-added (git.autoAdd = true in config)
# Commit from source directory
chezmoi cd
git commit -m "feat: description"
git push

# Or use chezmoi's git command
chezmoi git -- commit -m "feat: description"
```

## Configuration System

### Encryption
- Uses **age** encryption for sensitive files
- Private key: `~/age-key.txt`
- Encrypted files managed by chezmoi automatically
- Password manager: **rbw** (Bitwarden CLI)

### Template Variables
Available in `.tmpl` files:
- `{{ .chezmoi.sourceDir }}` - Source directory path
- `{{ .chezmoi.homeDir }}` - Home directory path
- `{{ .chezmoi.os }}` - Operating system (linux, darwin, windows)
- `{{ .chezmoi.arch }}` - Architecture (amd64, arm64, etc.)
- Custom data from `.chezmoi.toml.tmpl`:
  - `{{ .name }}` - "Tyler Butler"
  - `{{ .email }}` - "tyler@tylerbutler.com"
  - `{{ .codespaces }}` - Boolean for GitHub Codespaces

### Template Functions
- All Go template functions plus [Sprig functions](http://masterminds.github.io/sprig/)
- Shared templates: Store reusable templates in `.chezmoitemplates/` directory
- Include shared templates: `{{ template "shared.tmpl" . }}`
- Whitespace control: Use `{{-` and `-}}` to trim surrounding whitespace

### Platform-Specific Files
Use conditional templates or git includes:
- Git configs: `dot_config/git/*.gitconfig` with includeIf directives
- Shell configs: Conditional logic in `.zshrc`, `.bashrc`
- Platform detection: `$SYSTEM_TYPE` variable (Darwin, Linux, Windows)

## Development Workflow

### Adding New Dotfiles
1. If file already exists: `chezmoi add <file>`
2. If creating new: Create with proper prefix in source directory
3. For templates: Add `.tmpl` suffix and use template syntax
4. Apply: `chezmoi apply`

### Modifying Existing Files
1. **Preferred**: `chezmoi edit <file>` (edits in source directory)
2. Or: Edit directly in `~/.local/share/chezmoi/` and apply
3. **Avoid**: Editing files in home directory (changes will be overwritten)

### Installing on New System
```bash
# Ubuntu/WSL
curl -sfL https://git.io/chezmoi | sh
chezmoi init --apply --verbose https://github.com/tylerbutler/dotfiles.git

# Windows
choco install chezmoi git
chezmoi init --apply --verbose https://github.com/tylerbutler/dotfiles.git
```

## Special Configurations

### Shell Setup
- Primary shell: **zsh** with custom prompt via Starship
- Fallback: bash with similar configuration
- Plugin manager: Native zsh plugin loading from `dot_zsh_plugins.txt`
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
Package lists stored in:
- `dot_default-apt` - APT packages (Ubuntu/Debian)
- `dot_default-cargo-crates` - Rust crates
- `dot_default-eget` - Binary downloads via eget
- `dot_default-nix-packages` - Nix packages
- `dot_default-pacman-packages` - Arch packages
- `dot_default-chocolatey-packages.config` - Windows packages
- `dot_default-scoop-packages` - Windows Scoop packages

### Claude Code Integration
- Commands: `dot_claude/commands/` - Custom slash commands
- Agents: `dot_claude/agents/` - Specialized agent configurations
- Framework docs: `dot_claude/*.md` - SuperClaude framework documentation

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
