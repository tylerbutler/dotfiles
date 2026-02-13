# tylerbutler's dotfiles

These are my dotfiles. There are many like them, but these are mine.

## Installation

To setup a new box with these dotfiles you'll need [chezmoi][]. Once installed, use it to clone the dotfiles repo.


### Ubuntu / WSL

```bash
curl -sfL https://git.io/chezmoi | sh
chezmoi init --apply --verbose https://github.com/tylerbutler/dotfiles.git
```

### Windows

```powershell
choco install chezmoi git
chezmoi init --apply --verbose https://github.com/tylerbutler/dotfiles.git
```


## Install location

`~/.local/share/chezmoi`

## Post-install setup scripts

After `chezmoi apply`, these scripts are available in `~/.local/bin/` and can be run manually as needed.

### Platform setup

| Script | Platform | Description |
|--------|----------|-------------|
| `setup-apt` | Debian/Ubuntu | Install core APT packages, zsh, set default shell |
| `setup-pacman` | Arch Linux | Install core pacman packages, zsh, set default shell |
| `setup-scoop` | Windows | Install Scoop package manager |
| `setup-psmodules` | Windows | Install PowerShell modules |
| `setup-git-ppa` | Debian (non-WSL) | Add git-core PPA for latest stable git |
| `setup-beyondcompare` | Windows | Install Beyond Compare via Scoop |

### Tool installers

| Script | Description |
|--------|-------------|
| `install-brew` | Install Homebrew (skips if already installed) |
| `install-rustup` | Install rustup with minimal stable toolchain |
| `install-nix` | Install Nix package manager |
| `install-eget` | Install eget binary downloader |
| `install-docker` | Install Docker |
| `install-powershell` | Install PowerShell on Linux |
| `install-code` | Install VS Code via snap |
| `install-fonts` | Install fonts |
| `install-rclone` | Install rclone |
| `install-lazygit` | Install lazygit |
| `install-volta` | Install Volta (JS toolchain manager) |
| `install-plex` | Install Plex Media Server |
| `install-filebot` | Install FileBot |
| `install-handbrake` | Install HandBrake |
| `install-keybase` | Install Keybase |
| `install-vorta` | Install Vorta (BorgBackup GUI) |
| `install-base16-shell` | Install base16-shell color themes |

### Automatic scripts

These still run automatically via chezmoi:

| Script | Trigger | Description |
|--------|---------|-------------|
| `run_onchange_install-brewfile.sh` | Brewfile content changes | Runs `brew bundle` to sync Homebrew packages |

## Pulling updates from GitHub

You can pull updates using `chezmoi update`.


[chezmoi]: https://www.chezmoi.io/
