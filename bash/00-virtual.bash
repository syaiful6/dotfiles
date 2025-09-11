# rust setup
if [[ -e "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

# ghcup config
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env

if [[ -d "$HOME/.config/nvm" ]]; then
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opam configuration
# [[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>/dev/null

# phpenv
if [[ -d "$HOME/.config/phpenv" ]]; then
  export PHPENV_ROOT="$HOME/.config/phpenv"
  export PATH="$HOME/.config/phpenv/bin:$PATH"
  eval "$(phpenv init -)"
fi

if [ "$(uname -s)" = "Darwin" ]; then
  [[ $(arch) = "arm64" ]] &&
    eval "$(/opt/homebrew/bin/brew shellenv)" ||
    eval "$(/usr/local/Homebrew/bin/brew shellenv)"
else
  # assume it's a linux brew
  if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

export PATH="$HOME/.local/bin:$HOME/.rvm/bin:$PATH"
