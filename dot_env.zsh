# echo "=== .env.zsh START ==="

# We need this so that tmux uses zsh when started in a zsh shell
export SHELL='/bin/zsh'

export LANG='en_US.UTF-8'
export GPG_TTY=$(tty)
export BAT_CONFIG_PATH="$HOME/.bat.conf"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# paths for brew-installed python bins
# export PATH="$(brew --prefix)/opt/python/libexec/bin:$PATH"

# Preferred editor for local and remote sessions
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
    export EDITOR="micro"
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    esac
    export EDITOR="code"
fi

# echo "=== .env.zsh END ==="
