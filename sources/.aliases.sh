# shortcuts
alias :q="exit"
alias cls="clear"
alias reboot="sudo shutdown -r now"
alias zshconfig="$EDITOR ~/.zshrc"

# listings and navigation
alias cdr="cd-gitroot"
alias l="k --human"
alias ll="k --human --almost-all"
alias lsa="k --human --almost-all"
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
