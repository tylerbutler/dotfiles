if [ "$SYSTEM_TYPE" = "Darwin" ]; then

  # Setup fzf
  # ---------
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi

  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.bash" 2> /dev/null

  # Key bindings
  # ------------
  source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"

else

  # Setup fzf
  # ---------
  if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/home/linuxbrew/.linuxbrew/opt/fzf/bin"
  fi

  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.bash" 2> /dev/null

  # Key bindings
  # ------------
  source "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"

fi