
#!/bin/sh

# exit immediately if rbw is already in $PATH
type rbw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    # commands to install rbw on Darwin
    brew install rbw
    ;;
Linux)
    # commands to install rbw on Linux
    brew install rbw
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac