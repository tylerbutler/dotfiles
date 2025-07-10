#!/bin/sh

# exit immediately if ubi is already in $PATH
type ubi >/dev/null 2>&1 && exit

# Install ubi
curl --silent --location \
    https://raw.githubusercontent.com/houseabsolute/ubi/master/bootstrap/bootstrap-ubi.sh |
    TARGET="$HOME/.local/bin" sh