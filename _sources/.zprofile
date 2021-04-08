# if ! compaudit; then
#     echo "compaudit failed; fixing"
#     compaudit | xargs chown -R "tylerbu"
#     compaudit | xargs chmod go-w
# fi

#if [[ -z "$STY" ]]; then
#   screen -xRR default
#fi
# {{ if (eq .chezmoi.os "darwin") -}}

# eval "$(/opt/homebrew/bin/brew shellenv)"

# {{ end -}}
