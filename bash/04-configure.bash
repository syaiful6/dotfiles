if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  export TERM=xterm-256color
fi

# Disable XON/XOFF for Vim compatibility
stty -ixon