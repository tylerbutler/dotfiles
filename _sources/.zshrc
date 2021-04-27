#######
# zshrc
#######

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

GITSTATUS_LOG_LEVEL=DEBUG

# PATH updates
export PATH="/usr/sbin:/sbin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/snap/bin:$PATH"
export PATH="$PATH:/root/.local/bin"

export SYSTEM_TYPE=$(uname -s)

if [ "$SYSTEM_TYPE" = "Darwin" ]; then
     # eval $(gdircolors $HOME/.dir_colors)
     eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Antigen load and bootstrap
source $HOME/antigen.zsh
antigen init $HOME/.antigenrc

# Aliases
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

export LS_COLORS="$(vivid generate solarized-dark)"
# export LS_COLORS="$(vivid generate jellybeans)"
# test -r "$HOME/.dir_colors"
# eval $(dircolors $HOME/.dir_colors/nord.txt)

# load env variables
source $HOME/.env.zsh

fpath=($HOME/.zsh/completions $fpath)

# initialize completions with ZSH's compinit
autoload -Uz compinit
compinit

# eval "$(starship init zsh)"
# POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# nvm config; disabled and replaced by a zsh plugin
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# MAC OS ONLY
# fnm
if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    export PATH=/Users/tylerbu/.fnm:$PATH
    eval "`fnm env`"
fi
