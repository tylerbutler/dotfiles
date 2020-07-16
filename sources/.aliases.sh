# shortcuts
alias :q="exit"
alias cls="clear"
alias reboot="sudo shutdown -r now"
alias zshconfig="$EDITOR ~/.zshrc"

# Pipe my public key to my clipboard
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# listings and navigation
alias cdr="cd-gitroot"
alias k="k --human"
alias kl="k --human --almost-all"
alias l="ls "
alias ll="k --human --almost-all"
alias ls="ls --color -o "
alias lsa="\ls --color -oA "
alias mkdir="mkdir -p "

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
alias gst="git status -u ."
