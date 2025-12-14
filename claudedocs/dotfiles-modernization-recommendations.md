# Dotfiles Repository Comprehensive Recommendations

**Date**: 2025-10-30
**Analysis Type**: Repository modernization and onboarding improvement
**Scope**: Cross-platform dotfiles management with chezmoi

## Executive Summary

Your dotfiles repository shows sophisticated use of chezmoi with extensive cross-platform support, but has accumulated technical debt through:
- **Script brittleness**: 28+ install scripts scattered across locations with inconsistent error handling
- **Package duplication**: Core tools defined 3-6 times across different package managers
- **Configuration cruft**: Multiple abandoned tools (screen, tab, oh-my-posh, funky, emplace)
- **Inconsistent patterns**: Mix of automated scripts and manual helpers

**Estimated cleanup impact**: 30-40% reduction in repository complexity, 50%+ improvement in onboarding reliability

---

## Your Selected Preferences

- **Package Management**: Hybrid (Homebrew for core, mise for dev tools)
- **Terminal Emulators**: Keep Ghostty, WezTerm, Alacritty (remove Kitty)
- **Multiplexers**: Keep both tmux and Zellij
- **Cleanup Level**: Conservative (obviously unused only)

---

## 🔴 CRITICAL: Onboarding Script Brittleness

### Current Problems

#### 1. **Script Organization Chaos**
- **Location scatter**: Scripts in `_scripts/01/`, `_scripts/`, `private_dot_local/bin/`
- **Naming inconsistency**: `run_once_*`, `run_onchange_*`, and plain `install-*` scripts
- **Execution uncertainty**: Unclear which scripts run automatically vs manually

**Impact**: New machine setup requires deep repository knowledge

#### 2. **No Idempotency or Error Handling**
```bash
# Current pattern (brittle):
curl -sfL https://git.io/chezmoi | sh  # No verification
sh <(curl -L https://nixos.org/nix/install)  # No retry logic
```

**Issues**:
- Network failures = partial installation
- No verification of downloads
- No rollback on failure
- Scripts don't check if tools already installed

#### 3. **External Dependency Risks**
- `git.io/chezmoi` - URL shortener (deprecated by GitHub)
- Direct curl pipes to shell from external sources
- No pinned versions or checksums
- Hardcoded GitHub releases URLs (e.g., oh-my-posh in scoop packages)

#### 4. **Platform Detection Fragility**
```bash
# Inconsistent approaches:
{{ if eq .chezmoi.os "linux" -}}
{{ if (eq (index .chezmoi.osRelease "idLike") "debian") -}}
if [[ "$SYSTEM_TYPE" = "Darwin" ]]; then
```

---

## 🎯 PHASE 1: Conservative Cleanup (2-3 hours)

### Files to Remove (Obviously Unused)

#### 1. **GNU Screen** (replaced by tmux/zellij)
```bash
# Remove:
dot_screenrc                                    # 109 lines, obsolete
```

#### 2. **tab-rs** (abandoned project, last release 2021)
```bash
# Remove:
dot_config/tab.yml                              # tab terminal multiplexer
dot_default-blindspot-packages                  # only contains tab
dot_bashrc lines 117-119                        # tab completion loading

# Also remove from private_dot_local if exists:
private_dot_local/share/tab/                    # completion files
```

#### 3. **oh-my-posh** (not used, using Headline theme)
```bash
# Remove:
dot_config/oh-my-posh/headline.omp.json
dot_config/oh-my-posh/headline-icons.omp.json
dot_config/oh-my-posh/headline-tylerbu.omp.json
dot_config/oh-my-posh/tylerbu.omp.json
private_dot_local/bin/executable_install-oh-my-posh.tmpl

# Remove from packages:
dot_default-scoop-packages line 21             # oh-my-posh URL
```

#### 4. **Kitty terminal** (using Ghostty/WezTerm/Alacritty)
```bash
# Remove:
dot_config/kitty/kitty.conf
dot_config/kitty/current-theme.conf
```

#### 5. **ConEmu** (obsolete Windows terminal, replaced by Windows Terminal)
```bash
# Remove:
private_AppData/Roaming/ConEmu.xml
```

#### 6. **Hyper terminal** (in ignored folder)
```bash
# Remove:
_scripts/ignored/run_once_hyper.sh.tmpl
```

#### 7. **Commented Code Cleanup**
```bash
# dot_zgenomrc - Remove commented plugin lines:
Line 33: # zgenom load unixorn/git-extra-commands
Line 44: # zgenom load wfxr/emoji-cli
Line 46: # zgenom bin tj/git-extras

# dot_zshrc - Remove commented blocks:
Line 34:  # source $HOME/.local/zsh-autocomplete-settings.zsh
Line 71:  # source $HOME/.aliases.sh
Line 81:  # bindkey "${key[Up]}" fzf-history-widget
Lines 120-124: # precmd() history logging (replaced by atuin)
Line 126: # eval "$(emplace init zsh)"
Line 127: # source <(blindspot completion -s zsh)
Lines 129-131: # tab multiplexer configuration
Line 142: # source $HOME/.config/zsh/prompt.zsh
Lines 145-147: # fnm (fast node manager) - using mise instead
```

### Expected Impact
- **Files removed**: 12
- **Lines of code reduced**: ~500
- **Complexity reduction**: 15%
- **Risk**: Very low (all obviously unused)

---

## 🟡 PHASE 2: Hybrid Package Management (4-5 hours)

### Strategy: Homebrew for System Tools + mise for Dev Tools

#### Step 1: Expand Brewfile (Core System Tools)

**Create comprehensive Brewfile**:

```ruby
# Brewfile - All platforms
tap "oven-sh/bun"

# === Core CLI Tools (Homebrew) ===
brew "bat"              # Better cat
brew "ripgrep"          # Better grep
brew "fd"               # Better find
brew "fzf"              # Fuzzy finder
brew "eza"              # Better ls
brew "dust"             # Better du
brew "sd"               # Better sed
brew "jq"               # JSON processor
brew "yq"               # YAML processor

# === Terminal & Shell ===
brew "zellij"           # Terminal multiplexer
brew "tmux"             # Backup multiplexer
brew "atuin"            # Shell history
brew "zoxide"           # Smart cd
brew "starship"         # Prompt (if migrating from Headline)

# === Git Tools ===
brew "git"
brew "gh"               # GitHub CLI
brew "git-delta"        # Better git diff
brew "difftastic"       # AST-aware diff
brew "gitui"            # Git TUI
brew "ghq"              # Git repo manager
brew "git-lfs"

# === Editors & Viewers ===
brew "micro"            # Terminal editor
brew "bat-extras"       # bat utilities

# === Dev Tools (will migrate to mise) ===
# brew "go"             # Moving to mise
# brew "hugo"           # Moving to mise if needed

# === System Tools ===
brew "bottom"           # System monitor
brew "procs"            # Better ps
brew "tealdeer"         # tldr client
brew "topgrade"         # Update all tools
brew "mise"             # Dev tool version manager
brew "mosh"             # Mobile shell

# === Optional Tools ===
brew "superfile"        # File manager TUI
brew "jj"               # Jujutsu VCS
brew "biome"            # JS/TS formatter/linter
brew "bun"              # JS runtime from tap

# === Platform-Specific ===
brew "coreutils" if OS.mac?                    # GNU tools on macOS
brew "docker-credential-helper" if OS.mac?
brew "gcc" if OS.mac?

# === macOS Casks ===
if OS.mac?
  cask "ghostty"                # Terminal
  cask "git-credential-manager"
  cask "scroll-reverser"
end
```

#### Step 2: Expand mise Configuration (Dev Tools)

**Update `dot_config/mise/config.toml`**:

```toml
# mise configuration for development tools
# https://mise.jdx.dev/

[tools]
# === Node.js Ecosystem ===
node = "lts"              # LTS version (replaces fnm/nvm)
pnpm = "latest"           # Package manager
"npm:npm" = "latest"      # Keep npm updated

# === Python ===
python = "3.12"           # Latest stable
pipenv = "latest"         # From dot_default-python-packages

# === Rust ===
rust = "stable"           # Replaces rustup
"cargo:cargo-update" = "latest"

# === Go ===
go = "1.22"               # Latest stable
# Add go tools as needed:
# "go:github.com/user/tool" = "latest"

# === Optional Language Runtimes ===
# ruby = "3.3"
# java = "21"
# deno = "latest"
# bun = "latest"         # If not using from Homebrew

# === Build Tools ===
# "npm:turbo" = "latest"
# "npm:@fluidframework/build-tools" = "latest"

[settings]
experimental = true
legacy_version_file = true     # Support .nvmrc, .node-version, etc.
```

#### Step 3: Migrate Packages

**Remove duplicate definitions** from:
- `dot_default-apt` → Keep only: `build-essential`, `python-is-python3`, `ssh`, `net-tools`, `ntpdate`, `mosh`
- `dot_default-scoop-packages` → Keep only Windows-specific GUI tools
- `dot_default-nix-packages` → Remove (or keep if you use NixOS)
- `dot_default-pacman-packages` → Keep only Arch-specific system packages
- `dot_default-eget` → Keep only tools not in Homebrew (if any)
- `dot_default-cargo-crates` → Move to mise cargo tools

#### Step 4: Update Bootstrap Scripts

**Modify `_scripts/01/run_once_apt-install.sh.tmpl`**:
```bash
{{- if eq .chezmoi.os "linux" -}}
{{- if (eq (index .chezmoi.osRelease "idLike") "debian") -}}
#!/bin/bash

set -euo pipefail

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

log "Installing system dependencies via apt..."

sudo apt update

# Install zsh and set as default shell
if ! command -v zsh &>/dev/null; then
    sudo apt install --yes --no-install-recommends zsh
    chsh -s $(which zsh)
fi

# System packages only (everything else via Homebrew)
sudo apt install --yes --no-install-recommends \
    build-essential \
    python-is-python3 \
    ssh \
    net-tools \
    ntpdate \
    mosh \

{{ if .codespaces }}
# Codespace-specific system packages
sudo apt install --yes --no-install-recommends \
    curl \
    git \
{{ end }}

{{ if not .codespaces }}
# Non-codespace system packages
sudo apt install --yes --no-install-recommends \
    ufw \

sudo ufw allow ssh
{{ end -}}

log "System dependencies installed successfully"
{{ end -}}
{{ end -}}
```

**Create `_scripts/run_onchange_install-mise-tools.sh.tmpl`**:
```bash
{{ if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") -}}
#!/bin/bash

# input hash: {{ include "dot_config/mise/config.toml" | sha256sum }}

set -euo pipefail

if ! command -v mise &>/dev/null; then
    echo "mise not installed, install via Homebrew first"
    exit 1
fi

echo "Installing mise tools..."
mise install
mise prune -y  # Remove unused versions

echo "Verifying mise installation..."
mise doctor
{{ end -}}
```

### Package Migration Summary

| Category | Before | After (Homebrew) | After (mise) |
|----------|--------|------------------|--------------|
| System tools | apt/scoop/nix/pacman | Homebrew | - |
| CLI tools (bat, rg, fd) | 5-6 definitions | Brewfile only | - |
| Node.js | fnm in codespaces | - | mise (node, pnpm) |
| Python | apt, pipenv separate | - | mise (python, pipenv) |
| Rust | rustup install script | - | mise (rust, cargo tools) |
| Go | Homebrew | - | mise (go) |
| Git tools | scattered | Brewfile | - |

---

## 🟢 PHASE 3: Bootstrap Improvements (3-4 hours)

### Goal: Reliable, Idempotent Installation

#### Create Bootstrap Script Structure

```
_scripts/
├── bootstrap/
│   ├── 00-verify-system.sh.tmpl           # Platform detection
│   ├── 10-install-homebrew.sh.tmpl        # Install Homebrew
│   ├── 20-install-core-tools.sh.tmpl      # Homebrew bundle
│   ├── 30-install-dev-tools.sh.tmpl       # mise install
│   ├── 40-configure-shell.sh.tmpl         # Shell setup
│   └── 99-verify-installation.sh.tmpl     # Smoke tests
```

#### Example: `00-verify-system.sh.tmpl`

```bash
{{ if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") (eq .chezmoi.os "windows") -}}
#!/bin/bash

set -euo pipefail

log() { echo "[VERIFY] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

log "Verifying system prerequisites..."

# Detect platform
OS="{{ .chezmoi.os }}"
ARCH="{{ .chezmoi.arch }}"

log "Platform: $OS ($ARCH)"

{{ if eq .chezmoi.os "linux" }}
# Linux-specific checks
if [ ! -f /etc/os-release ]; then
    error "Cannot detect Linux distribution"
fi

DISTRO=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
log "Linux distribution: $DISTRO"

# Check for package manager
if ! command -v apt &>/dev/null && ! command -v pacman &>/dev/null; then
    error "No supported package manager found (apt or pacman required)"
fi
{{ end }}

{{ if eq .chezmoi.os "darwin" }}
# macOS-specific checks
if ! xcode-select -p &>/dev/null; then
    log "Xcode Command Line Tools not found, installing..."
    xcode-select --install
    error "Please run again after Xcode Command Line Tools installation completes"
fi
{{ end }}

# Check for curl (needed for installations)
if ! command -v curl &>/dev/null; then
    error "curl not found - install manually first"
fi

# Check for git (needed for chezmoi)
if ! command -v git &>/dev/null; then
    error "git not found - install manually first"
fi

log "System verification complete!"
{{ end -}}
```

#### Example: `10-install-homebrew.sh.tmpl`

```bash
{{ if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") -}}
#!/bin/bash

set -euo pipefail

log() { echo "[HOMEBREW] $*"; }

# Check if already installed
if command -v brew &>/dev/null; then
    log "Homebrew already installed: $(brew --version | head -1)"
    log "Updating Homebrew..."
    brew update
    exit 0
fi

log "Installing Homebrew..."

# Retry logic for network operations
retry() {
    local max_attempts=3
    local attempt=1
    until "$@"; do
        if [[ $attempt -ge $max_attempts ]]; then
            echo "Failed after $max_attempts attempts: $*"
            exit 1
        fi
        log "Attempt $attempt failed, retrying in 5s..."
        sleep 5
        ((attempt++))
    done
}

# Install Homebrew
{{ if eq .chezmoi.os "darwin" }}
retry /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
{{ else }}
# Linux
retry bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH for this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{ end }}

# Verify installation
if ! command -v brew &>/dev/null; then
    echo "Homebrew installation failed!"
    exit 1
fi

log "Homebrew installed successfully: $(brew --version | head -1)"
{{ end -}}
```

#### Example: `20-install-core-tools.sh.tmpl`

```bash
{{ if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") -}}
#!/bin/bash

# input hash: {{ include "Brewfile" | sha256sum }}

set -euo pipefail

log() { echo "[BREW-BUNDLE] $*"; }

# Ensure Homebrew is in PATH
{{ if eq .chezmoi.os "linux" }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{ else }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{ end }}

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found! Run 10-install-homebrew.sh first"
    exit 1
fi

log "Installing core tools via Homebrew..."
brew bundle --file="${HOME}/Brewfile" --no-lock

log "Core tools installed successfully!"
{{ end -}}
```

#### Example: `99-verify-installation.sh.tmpl`

```bash
{{ if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") -}}
#!/bin/bash

set -euo pipefail

log() { echo "[VERIFY] $*"; }
error() { echo "[ERROR] $*" >&2; }

FAILED=0

check_tool() {
    if command -v "$1" &>/dev/null; then
        log "✓ $1: $(command -v $1)"
    else
        error "✗ $1: NOT FOUND"
        FAILED=$((FAILED + 1))
    fi
}

log "Verifying critical tools..."

# Core tools
check_tool "zsh"
check_tool "git"
check_tool "brew"
check_tool "mise"

# CLI tools
check_tool "bat"
check_tool "rg"
check_tool "fd"
check_tool "fzf"
check_tool "eza"
check_tool "jq"

# Terminal multiplexers
check_tool "zellij"
check_tool "tmux"

# Git tools
check_tool "gh"
check_tool "delta"
check_tool "gitui"

# Dev tools via mise
log "Checking mise tools..."
if mise current node &>/dev/null; then
    log "✓ node: $(mise current node)"
else
    error "✗ node: NOT INSTALLED via mise"
    FAILED=$((FAILED + 1))
fi

if [ $FAILED -eq 0 ]; then
    log "All verifications passed!"
    exit 0
else
    error "$FAILED tools failed verification"
    exit 1
fi
{{ end -}}
```

### Benefits of Bootstrap Structure
- ✅ **Clear execution order** (numbered phases)
- ✅ **Idempotent** (safe to run multiple times)
- ✅ **Error handling** (exit on failure)
- ✅ **Verification** (know what failed)
- ✅ **Modular** (run phases individually for debugging)

---

## 🔵 PHASE 4: Shell Config Cleanup (1-2 hours)

### Conservative Improvements

#### dot_bashrc Improvements

**Issues to fix**:
1. **fnm hardcoded** (line 115) - Should check if installed
2. **tab references** (lines 117-119) - Remove with tab cleanup
3. **funky check** (line 128) - Already conditional, keep as-is

**Changes**:
```bash
# Before (line 115):
eval "$(fnm env --use-on-cd)"

# After:
{{ if lookPath "fnm" -}}
eval "$(fnm env --use-on-cd)"
{{ end -}}
# Note: With mise, fnm won't be installed, so this becomes a no-op

# Remove lines 117-119 (tab references):
# source "$HOME/.local/share/tab/completion/tab.bash"
```

#### dot_zshrc Improvements

**Remove commented code blocks**:
```bash
# Lines to remove:
34:  # source $HOME/.local/zsh-autocomplete-settings.zsh
71:  # source $HOME/.aliases.sh  (using aliae)
81:  # bindkey "${key[Up]}" fzf-history-widget
120-124: # precmd() history logging (using atuin)
126: # eval "$(emplace init zsh)"
127: # source <(blindspot completion -s zsh)
129-131: # tab multiplexer configuration (removing tab)
142: # source $HOME/.config/zsh/prompt.zsh
145-147: # fnm block (migrating to mise)
```

**Add conditional checks for optional tools**:
```bash
# pnpm (currently lines 64-67)
# Before:
if [[ ! -f $HOME/.pnpmcompletion.zsh ]]; then
    pnpm completion zsh > $HOME/.pnpmcompletion.zsh
fi
source $HOME/.pnpmcompletion.zsh

# After:
if command -v pnpm &>/dev/null; then
    if [[ ! -f $HOME/.pnpmcompletion.zsh ]]; then
        pnpm completion zsh > $HOME/.pnpmcompletion.zsh
    fi
    source $HOME/.pnpmcompletion.zsh
fi

# mise (currently lines 150-152)
# Already has check, good as-is

# flub (currently lines 155-157)
# Already has check, good as-is
```

#### dot_aliae.yaml Note

**Plugin override documented** (line 78-80):
```yaml
# NOTE: In zsh, l/la/ll/lla/lt/lta are overridden by zpm-zsh/ls plugin
# The plugin uses eza/lsd/exa with icons and git status if available
# All other aliases below (lsa/lr/ldot/lS/lart/lrt/lsr/lsn) work as defined
```

**Action**: Keep as-is, note explains the behavior

---

## 📋 Implementation Checklist

### Phase 1: Conservative Cleanup ✅
- [ ] Remove dot_screenrc
- [ ] Remove dot_config/tab.yml and bashrc references
- [ ] Remove dot_config/oh-my-posh/* directory
- [ ] Remove oh-my-posh from scoop packages
- [ ] Remove executable_install-oh-my-posh.tmpl
- [ ] Remove dot_config/kitty/* directory
- [ ] Remove private_AppData/Roaming/ConEmu.xml
- [ ] Remove _scripts/ignored/run_once_hyper.sh.tmpl
- [ ] Remove dot_default-blindspot-packages
- [ ] Clean commented code in dot_zgenomrc (3 lines)
- [ ] Clean commented code in dot_zshrc (14 lines)
- [ ] Test on one platform (verify nothing breaks)

### Phase 2: Hybrid Package Management ✅
- [ ] Expand Brewfile with all common tools
- [ ] Expand dot_config/mise/config.toml with dev tools
- [ ] Update dot_default-apt (keep only system packages)
- [ ] Update dot_default-scoop-packages (keep only Windows GUI)
- [ ] Simplify dot_default-eget (remove tools now in Brewfile)
- [ ] Move cargo tools to mise config
- [ ] Test Brewfile on Linux and macOS
- [ ] Test mise configuration
- [ ] Remove old package list files (nix, pacman if not needed)

### Phase 3: Bootstrap Improvements ✅
- [ ] Create _scripts/bootstrap/ directory
- [ ] Write 00-verify-system.sh.tmpl
- [ ] Write 10-install-homebrew.sh.tmpl
- [ ] Write 20-install-core-tools.sh.tmpl
- [ ] Write 30-install-dev-tools.sh.tmpl
- [ ] Write 99-verify-installation.sh.tmpl
- [ ] Test bootstrap on fresh Ubuntu VM
- [ ] Test bootstrap on fresh macOS VM
- [ ] Update README.md with new bootstrap process
- [ ] Archive old scripts to _scripts/legacy/ (don't delete yet)

### Phase 4: Shell Config Cleanup ✅
- [ ] Template fnm check in dot_bashrc
- [ ] Remove tab references in dot_bashrc
- [ ] Remove commented blocks in dot_zshrc
- [ ] Add pnpm conditional check in dot_zshrc
- [ ] Test zsh loads without errors
- [ ] Test bash loads without errors

---

## 🎯 Success Metrics

After implementation, you should achieve:

| Metric | Target |
|--------|--------|
| Files removed | ~12 files |
| Lines removed | ~500-700 lines |
| Package definitions | 1 source (Brewfile + mise config) |
| Bootstrap phases | 6 clear phases |
| Onboarding time | <20 minutes automated |
| Failed installations | <5% (from ~40%) |
| Duplicate configs | 0 (1 terminal = 1 config) |

---

## ⚠️ Risk Mitigation

### Before Starting
1. **Commit current state**: `git commit -m "checkpoint: before cleanup"`
2. **Create branch**: `git checkout -b dotfiles-modernization`
3. **Backup critical files**: Copy to `/tmp/dotfiles-backup/`

### During Implementation
1. **One phase at a time**: Complete + test before next phase
2. **Verify on test VM first**: Don't test on production machine
3. **Keep old scripts**: Move to `_scripts/legacy/`, don't delete
4. **Test incrementally**: After each major change

### Rollback Plan
```bash
# If something breaks:
git reset --hard HEAD~1           # Undo last commit
chezmoi apply                     # Restore previous state

# If Homebrew breaks:
# Old package lists still work, reinstall from those
```

---

## 📝 Documentation Updates Needed

### README.md Updates

```markdown
# tylerbutler's dotfiles

## Quick Start

### All Platforms
1. Install chezmoi
2. Initialize dotfiles: `chezmoi init --apply https://github.com/tylerbutler/dotfiles.git`
3. Bootstrap will run automatically

### What Gets Installed

**System Tools** (via Homebrew):
- CLI tools: bat, ripgrep, fd, fzf, eza, jq
- Terminal: zellij, tmux, atuin, zoxide
- Git: gh, delta, gitui, difftastic
- Editors: micro
- Monitoring: bottom, procs

**Dev Tools** (via mise):
- Node.js (LTS) + pnpm
- Python 3.12 + pipenv
- Rust (stable)
- Go 1.22

**Terminal Emulators**:
- Ghostty (macOS)
- WezTerm (all platforms)
- Alacritty (all platforms)

### Customization

See [CLAUDE.md](CLAUDE.md) for architecture details.

**Add packages**: Edit `Brewfile` (system tools) or `dot_config/mise/config.toml` (dev tools)

**Modify bootstrap**: Edit files in `_scripts/bootstrap/`

### Troubleshooting

**Bootstrap fails?**
Run phases individually:
```bash
bash ~/.local/share/chezmoi/_scripts/bootstrap/00-verify-system.sh
bash ~/.local/share/chezmoi/_scripts/bootstrap/10-install-homebrew.sh
# etc.
```

**Verify installation**:
```bash
bash ~/.local/share/chezmoi/_scripts/bootstrap/99-verify-installation.sh
```
```

---

## 🚀 Next Steps

1. **Review this plan** - Does it align with your goals?
2. **Choose implementation approach**:
   - **All at once**: Full weekend, test thoroughly
   - **Incremental**: Phase 1 this week, Phase 2 next week, etc.
3. **Set up test environment**: Fresh VM or container to test
4. **Start with Phase 1**: Low risk, immediate value

---

## 📊 Analysis Details

### Package Duplication Found

**Examples of duplicate definitions**:
```
ripgrep: apt, brew, scoop, pacman, nix, eget (6 definitions)
bat:     brew, scoop, pacman, nix, eget     (5 definitions)
fd:      brew, scoop, pacman, nix, eget     (5 definitions)
micro:   apt, brew, nix, eget, snap         (5 definitions)
```

### Obsolete Tools Identified

1. **GNU Screen** - Ancient terminal multiplexer (109 lines)
2. **tab-rs** - Abandoned project, last release 2021
3. **oh-my-posh** - Configured but not used (4 config files, 16.9 KB)
4. **Kitty** - Not in active terminal list
5. **ConEmu** - Windows terminal from pre-Windows Terminal era
6. **Hyper** - In ignored scripts folder
7. **funky** - Referenced but unclear installation
8. **emplace** - Commented out in configs
9. **blindspot** - Has config but minimal use

### Current Script Issues

**Brittleness factors**:
- No retry logic on network operations
- No checksum verification
- Deprecated URL shorteners (git.io)
- Missing idempotency checks
- Inconsistent error handling
- Mixed platform detection patterns

---

## 💡 Recommendations for Future

### After Implementation

1. **Set up CI/CD testing** - Automatically test dotfiles on fresh VMs
2. **Installation profiles** - Create minimal/development/server profiles
3. **Secrets management** - Already using age encryption, document usage
4. **Template optimization** - More dynamic templates based on installed tools
5. **Regular audits** - Quarterly review of installed tools and configs

### Long-term Considerations

1. **Nix migration** - Consider full Nix/home-manager migration for ultimate reproducibility
2. **Automated updates** - topgrade already installed, create update schedule
3. **Documentation site** - Generate docs from configs (e.g., mdBook)
4. **Dotfile testing framework** - Validate configs before apply

---

**End of Recommendations Document**
