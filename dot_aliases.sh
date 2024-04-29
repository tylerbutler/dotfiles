echo "=== .aliases START ==="

# shortcuts
alias :q="exit"
alias cls="clear"
alias reboot="sudo shutdown -r now"
alias reset-time="sudo ntpdate -sb time.nist.gov"
alias zshconfig="$EDITOR ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"

# I find typing 'chezmoi' awkward
alias dotfiles=chezmoi
alias df=chezmoi

# Pipe my public key to the clipboard
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# listings and navigation
alias cdr="cd-gitroot"
# general use

if command -v fnm >/dev/null 2>&1; then
	alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
	alias ls='eza -lbF --git'                                                   # ls
	alias l='eza --git'                                 # list, size, type, git
	alias ll='eza -lbGF --git'                               # long list
	alias llm='eza -lbGd --git --sort=modified'                            # long list, modified date sort
	alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

	# specialty views
	# alias lS='eza -1'                                                       # one column, just names
	alias lt='eza --tree --level=2'                                         # tree
fi

alias mkdir="mkdir -p "

# list only directories
# alias lsd='ls -d */'
# list only files
#alias lsf="ls -rtF | grep -v '.*/'"
#alias l='ls -l'

# grc overrides for ls; brew install coreutils
# if $(gls &>/dev/null)
# then
#   alias ls="gls -F --color"
#   alias l="gls -lAh --color"
#   alias ll="gls -l --color"
#   alias la="gls -A --color"
# fi

# disk usage
alias du='du -hd1 | sort -h'

# git
alias gcam="git add -A && git commit -m"
alias gcd="cd-gitroot"
alias glo="git log --oneline --decorate --graph -10"
alias glr="git pull --rebase"
alias gpo="git push -u origin HEAD"
alias gst="git status -u ."
alias gs="hub sync"
alias gsv="HUB_VERBOSE=1 hub sync"
alias gsc="git clone --filter=tree:0"
alias gnd="git clean -dn"
alias gndd="git clean -df"

alias default-blindspot-packages="xargs blindspot install <~/.default-blindspot-packages"
alias default-brew="xargs brew install <~/.default-brew"
alias default-cargo-crates="xargs cargo install <~/.default-cargo-crates"
alias default-eget="xargs eget <~/.default-eget"
alias default-nix-packages="xargs nix-env -iA <~/.default-nix-packages"
alias default-npm-packages="xargs npm i -g <~/.default-npm-packages"
alias extra-npm-packages="xargs npm i -g <~/.extra-npm-packages"
alias default-pacman="sudo xargs pacman -Syyu --needed --noconfirm <~/.default-pacman-packages"
alias default-python-packages="xargs pip install <~/.default-python-packages"

alias zfs-space="zfs list -o space -r deadpool wolverine x23"
alias zfs-snaps="zfs list -t snapshot -S creation "
alias zfs-sync="syncoid --no-stream --no-sync-snap --create-bookmark "
alias zfs-snap-delete="sudo zfs destroy -v "

alias rmlint="\rmlint -g -C "

# brew
alias b="brew"
alias bupd="brew update && brew outdated"
alias bupg="brew upgrade"

alias p="pnpm"
alias pi="pnpm i --frozen-lockfile"
# macOS-specific aliases
if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    alias dircolors="gdircolors"
fi

# I use fnm for node management on Linux and mac, but nvs on Windows
alias nvm="fnm"
alias nvs="fnm"

alias edit="$EDITOR"
alias aliases="$EDITOR $HOME/.aliases.sh"
alias refreshenv="omz reload"

alias ssh="ssh-ident"

echo "=== .aliases END ==="
