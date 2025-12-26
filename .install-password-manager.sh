#!/bin/sh

# This script handles rbw (Bitwarden CLI) setup for chezmoi.
# It is designed to be non-blocking and gracefully handle cases where:
# - rbw is not installed (exits silently)
# - rbw unlock is cancelled by user (continues without error)
# - rbw sync fails (continues without error)
#
# To force installation of rbw, set CHEZMOI_INSTALL_RBW=true

# Exit silently if rbw is not installed - don't force install unless requested
if ! type rbw >/dev/null 2>&1; then
    if [ "$CHEZMOI_INSTALL_RBW" = "true" ]; then
        case "$(uname -s)" in
        Darwin)
            sh "$CHEZMOI_SOURCE_DIR/.install-rbw.darwin.sh"
            ;;
        Linux)
            sh "$CHEZMOI_SOURCE_DIR/.install-rbw.linux.sh"
            ;;
        *)
            echo "rbw installation: unsupported OS"
            exit 0
            ;;
        esac
    else
        # rbw not installed and not requested - exit silently
        exit 0
    fi
fi

# rbw is installed - try to unlock and sync, but don't fail if user cancels
# The || true ensures we exit 0 even if unlock/sync fails
rbw unlock && rbw sync || true