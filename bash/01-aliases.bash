alias docomp='docker run --rm --interactive --tty --volume "$PWD":/app composer'

# alias for tmux
tmux="TERM=screen-256color-bce tmux"

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
