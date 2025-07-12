#!/bin/sh

# exit immediately if rbw is already in $PATH
if type rbw >/dev/null 2>&1; then
    rbw unlock && rbw sync
    exit
fi

export CHEZMOI_SOURCE_PATH="$(chezmoi source-path)"

case "$(uname -s)" in
Darwin)
    # commands to install rbw on Darwin
    sh "$CHEZMOI_SOURCE_PATH/.install-rbw.darwin.sh"
    ;;
Linux)
    # commands to install rbw on Linux
    sh "$CHEZMOI_SOURCE_PATH/.install-rbw.linux.sh"
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac