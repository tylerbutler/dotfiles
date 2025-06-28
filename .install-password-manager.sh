#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type bw >/dev/null 2>&1 && exit

npm install -g @bitwarden/cli

bw config server https://vaultwarden.btlr.org
bw unlock --raw > $HOME/.bwsession
