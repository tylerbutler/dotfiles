# shortcuts
alias :q="exit"
alias cls="clear"
alias reboot="sudo shutdown -r now"
alias reset-time="sudo ntpdate -sb time.nist.gov"
alias zshconfig="$EDITOR ~/.zshrc"

# I find typing 'chezmoi' awkward
alias dotfiles=chezmoi

# Pipe my public key to the clipboard
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# listings and navigation
alias cdr="cd-gitroot"
# general use
alias ls='exa'                                                          # ls
alias l='exa -lbF --git'                                                # list, size, type, git
alias ll='exa -lbGF --git'                                             # long list
alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# specialty views
alias lS='exa -1'                                                              # one column, just names
alias lt='exa --tree --level=2'                                         # tree

alias k="k --human"
alias kl="k --human --almost-all"
#alias l="ls "
#alias ll="exa -l"
#alias ls="ls --color -o "
#alias lsa="\ls --color -oA "
alias mkdir="mkdir -p "

# list only directories
alias lsd='ls -d */'
# list only files
#alias lsf="ls -rtF | grep -v '.*/'"
#alias l='ls -l'

# grc overides for ls; brew install coreutils
# if $(gls &>/dev/null)
# then
#   alias ls="gls -F --color"
#   alias l="gls -lAh --color"
#   alias ll="gls -l --color"
#   alias la="gls -A --color"
# fi

# disk usage
alias df="df -h "
alias du='du -hd1 | sort -h'

# git
alias gpo="git push -u origin HEAD"
alias gst="git status -u ."
alias gs="git sync"
alias gsc="git clone --filter=tree:0"

alias default-npm-packages="npm i -g pnpm; xargs pnpm i -g <~/.default-npm-packages"

alias zfs-space="zfs list -o space -r deadpool wolverine x23"
alias zfs-snaps="zfs list -t snapshot -S creation "
alias zfs-sync="syncoid --no-stream --no-sync-snap --create-bookmark "
alias zfs-snap-delete="sudo zfs destroy -v "

alias rmlint="\rmlint -g -C "
