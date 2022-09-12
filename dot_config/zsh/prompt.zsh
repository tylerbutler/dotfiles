# PROMPT CONFIG

# eval "$(starship init zsh)"

if [ "$CODESPACES" = true ]; then
	# do something
fi

# oh-my-posh
# eval "$(oh-my-posh --init --shell zsh --config ~/.config/oh-my-posh/headline-tylerbu.omp.json)"

# headline zsh theme
source ~/.config/themes/zsh/headline.zsh-theme
HEADLINE_DO_GIT_STATUS_COUNTS=true
HEADLINE_LINE_MODE="on"
HEADLINE_STATUS_TO_STATUS=""
HEADLINE_USER_BEGIN=""

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
