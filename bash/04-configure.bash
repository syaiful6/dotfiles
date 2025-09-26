if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  export TERM=xterm-256color
fi

export EDITOR='nvim'

# Disable XON/XOFF for Vim compatibility
stty -ixon

# GPG Configuration
export GPG_TTY=$(tty)

