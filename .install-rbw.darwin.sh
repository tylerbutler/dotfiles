#!/bin/sh

# exit immediately if rbw is already in $PATH
type rbw >/dev/null 2>&1 && exit

# Install brew if needed
sh $HOME/.local/share/chezmoi/.install-brew.sh

brew install rbw
