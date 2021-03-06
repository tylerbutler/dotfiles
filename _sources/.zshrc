#######
# zshrc
#######

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

GITSTATUS_LOG_LEVEL=DEBUG

export SYSTEM_TYPE=$(uname -s)

if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    # eval $(gdircolors $HOME/.dir_colors)
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
source $HOME/antigen.zsh
antigen init $HOME/.antigenrc

# Setting rg as the default source for fzf
export FZF_DEFAULT_OPTS="--height 96%"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Aliases
echo "aliases init"
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

# initialize completions with ZSH's compinit
autoload -Uz compinit
compinit

# curl -L https://raw.githubusercontent.com/ogham/exa/master/completions/completions.zsh > $HOME/.zsh/completions/_exa

# eval "$(starship init zsh)"
eval "$(oh-my-posh --init --shell zsh --config ~/.tylerbu.omp.json)"
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# nvm config; disabled and replaced by a zsh plugin
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Base16 Shell
# echo "base16 shell"
# BASE16_SHELL="$HOME/.config/base16-shell/"
# [ -n "$PS1" ] && \
    # [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        # eval "$("$BASE16_SHELL/profile_helper.sh")"

# MAC OS ONLY
# fnm
if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    echo "fnm init"
    export PATH="$HOME/.fnm:$PATH"
    eval "`fnm env`"
fi
