# We need this so that tmux uses zsh when started in a zsh shell
export SHELL='/bin/zsh'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='nano'
fi
