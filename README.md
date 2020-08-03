# tylerbutler's dotfiles

These are my dotfiles. There are many like them, but these are mine.

## Installation

To setup a new box with these dotfiles you'll need [chezmoi][]. Once installed, use it to clone the dotfiles repo.


### Ubuntu

```bash
snap install chezmoi --classic
chezmoi init --apply --verbose git@github.com:tylerbutler/dotfiles.git
```


### Windows

```powershell
choco install chezmoi
chezmoi init --apply --verbose https://github.com/tylerbutler/dotfiles.git
```


## Install location

`~/.local/share/chezmoi`


## Making changes to dotfiles

TODO


### Adding files to chezmoi as symlinks

TODO


## Pulling updates from GitHub

You can pull updates using `chezmoi update`.


[chezmoi]: https://www.chezmoi.io/
