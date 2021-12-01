source $HOME/.local/share/chezmoi/_sources/.zshrc

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# base16_flat

# base16_atelier-estuary
base16_helios
# base16_hopscotch
# base16_materia
# base16_paraiso
# base16_tomorrow-night-eighties
function gig() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}
