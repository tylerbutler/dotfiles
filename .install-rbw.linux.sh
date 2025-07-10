#!/bin/sh

# exit immediately if rbw is already in $PATH
type rbw >/dev/null 2>&1 && exit

case "$(arch)" in
arm64)
    # commands to install rbw on Darwin
    sh .install-runstup.sh
    cargo install rbw
    ;;
amd64)
    # Download the .deb package
    tmp_deb="/tmp/rbw_1.9.0_amd64.deb"
    curl -L -o "$tmp_deb" "https://git.tozt.net/rbw/releases/deb/rbw_1.9.0_amd64.deb"

    # Install the package
    sudo dpkg -i "$tmp_deb"

    # Clean up
    rm -f "$tmp_deb"
    ;;
*)
    echo "unsupported architecture: $(arch)"
    exit 1
    ;;
esac
