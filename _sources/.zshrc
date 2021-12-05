#######
# zshrc
#######

zstyle ':autocomplete:*' default-context history-incremental-search-backward
# '': Start each new command line with normal autocompletion.
# history-incremental-search-backward: Start in live history search mode.

zstyle ':autocomplete:*' min-delay 0.0  # float
# Wait this many seconds for typing to stop, before showing completions.

zstyle ':autocomplete:*' min-input 1  # int
# Wait until this many characters have been typed, before showing completions.

zstyle ':autocomplete:*' recent-dirs zoxide
# cdr:  Use Zsh's `cdr` function to show recent directories as completions.
# no:   Don't show recent directories.
# zsh-z|zoxide|z.lua|z.sh|autojump|fasd: Use this instead (if installed).
# ⚠️ NOTE: This setting can NOT be changed at runtime.

zstyle ':autocomplete:*' insert-unambiguous no
# no:  Tab inserts the top completion.
# yes: Tab first inserts a substring common to all listed completions, if any.

zstyle ':autocomplete:*' widget-style complete-word
# complete-word: (Shift-)Tab inserts the top (bottom) completion.
# menu-complete: Press again to cycle to next (previous) completion.
# menu-select:   Same as `menu-complete`, but updates selection in menu.
# ⚠️ NOTE: This setting can NOT be changed at runtime.

zstyle ':autocomplete:*' fzf-completion yes
# no:  Tab uses Zsh's completion system only.
# yes: Tab first tries Fzf's completion, then falls back to Zsh's.
# ⚠️ NOTE: This setting can NOT be changed at runtime and requires that you
# have installed Fzf's shell extensions.

source $HOME/.local/zsh-autocomplete/zsh-autocomplete.plugin.zsh # see .chezmoiexternals.toml

GITSTATUS_LOG_LEVEL=DEBUG

if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

if [ "$SYSTEM_TYPE" = "Linux" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fpath=(/home/linuxbrew/.linuxbrew/share/zsh/site-functions $fpath)
    eval "$(pyenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
# eval "$(pyenv init --path)"

fpath=($HOME/.zsh/completions $fpath)

# Antigen load and bootstrap
source $HOME/.local/antigen.zsh # see .chezmoiexternals.toml
# source $HOME/antigen.zsh

antigen init $HOME/.antigenrc

# Setting rg as the default source for fzf
export FZF_DEFAULT_OPTS="--height 96%"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Aliases
# echo "aliases init"
source $HOME/.aliases.sh

# ZSH settings
##############
# Enable command auto-correction
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS="true"

# Save all history
# Incrementally write history to file
setopt INC_APPEND_HISTORY
# Save timestamp to history file too
setopt EXTENDED_HISTORY
# Import newly written commands from the history file
setopt SHARE_HISTORY
setopt extended_glob
setopt longlistjobs

precmd() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history | tail -n 1)" >>! $HOME/history/zsh-history-$(date "+%Y-%m-%d").log;
    fi
}

# export LS_COLORS="$(vivid generate solarized-dark)"
# export LS_COLORS="$(vivid generate jellybeans)"
# test -r "$HOME/.dir_colors"
# eval $(dircolors $HOME/.dir_colors/nord.txt)

# load env variables
source $HOME/.env.zsh

# eval "$(emplace init zsh)"
# source <(blindspot completion -s zsh)

# initialize completions with ZSH's compinit
# autoload -Uz compinit
# compinit

# curl -L https://raw.githubusercontent.com/ogham/exa/master/completions/completions.zsh > $HOME/.zsh/completions/_exa

# PROMPT CONFIG
# eval "$(starship init zsh)"
# eval "$(oh-my-posh --init --shell zsh --config ~/.tylerbu.omp.json)"
# eval "$(oh-my-posh --init --shell zsh --config ~/.headline.omp.json)"
source $HOME/_vendor/headline.zsh-theme
HEADLINE_DO_GIT_STATUS_COUNTS=true
HEADLINE_LINE_MODE="on"

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# fnm (fast node manager)
# echo "fnm init"
export PATH="$HOME/.fnm:$PATH"
eval "`fnm env`"

function gig() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}
