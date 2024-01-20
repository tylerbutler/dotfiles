# PROMPT CONFIG

headlinePrompt() {
	# headline zsh theme
	source ~/.config/themes/zsh/headline.zsh-theme
	HEADLINE_DO_GIT_STATUS_COUNTS=true
	HEADLINE_LINE_MODE="on"
	HEADLINE_STATUS_TO_STATUS=""
	HEADLINE_USER_BEGIN=""	
}

starshipPrompt() {
	if command -v starship >/dev/null 2>&1; then
		# starship
		eval "$(starship init zsh)"	
	else
		headlinePrompt
	fi
}

if [ "$CODESPACES" = true ]; then
	headlinePrompt
else
	starshipPrompt
fi

# oh-my-posh
# eval "$(oh-my-posh --init --shell zsh --config ~/.config/oh-my-posh/headline-tylerbu.omp.json)"

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
