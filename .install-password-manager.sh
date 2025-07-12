#!/bin/sh

# List all environment variables that start with CHEZMOI_
# env | grep '^CHEZMOI_'

# exit immediately if rbw is already in $PATH
if type rbw >/dev/null 2>&1; then
    rbw unlock && rbw sync
    exit
fi

case "$(uname -s)" in
Darwin)
    # commands to install rbw on Darwin
    sh "$CHEZMOI_SOURCE_DIR/.install-rbw.darwin.sh"
    ;;
Linux)
    # commands to install rbw on Linux
    sh "$CHEZMOI_SOURCE_DIR/.install-rbw.linux.sh"
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac