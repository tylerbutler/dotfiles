#!/bin/sh

case "$(uname -s)" in
Darwin)
    # commands to install rbw on Darwin
    sh .install-rbw.darwin.sh
    ;;
Linux)
    # commands to install rbw on Linux
    sh .install-rbw.linux.sh
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac