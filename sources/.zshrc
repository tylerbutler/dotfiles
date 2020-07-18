#######
# zshrc
#######

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH updates
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/snap/bin:$PATH"

# Antigen load and bootstrap
source $HOME/antigen.zsh
antigen init $HOME/.antigenrc

# Aliases
source ~/.aliases.sh

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

precmd() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history | tail -n 1)" >>! $HOME/history/zsh-history-$(date "+%Y-%m-%d").log;
    fi
}

source $HOME/.zsh/completions/chezmoi.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

export LS_COLORS="$(vivid generate solarized-dark)"
# export LS_COLORS="$(vivid generate jellybeans)"
source ~/.env.zsh
