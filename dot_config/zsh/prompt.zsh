# PROMPT CONFIG

headlinePrompt() {
	# headline zsh theme
	source $HOME/.config/themes/zsh/headline.zsh-theme
	HL_THIN='off'
	HL_OVERWRITE='on'
	HL_GIT_COUNT_MODE='on'
	HL_GIT_SEP_SYMBOL='|'
	HL_CLOCK_MODE='on'
	HL_ERR_MODE='detail'
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
