# We need this so that tmux uses zsh when started in a zsh shell
export SHELL='/bin/zsh'

export LANG='en_US.UTF-8'

export BAT_CONFIG_PATH="$HOME/.bat.conf"

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
