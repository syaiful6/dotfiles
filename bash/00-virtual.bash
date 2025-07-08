if [[ -d "$HOME/.cargo" ]]; then
  . "$HOME/.cargo/env"
fi

# ghcup config
[ -f "/Users/syaifulbahri/.ghcup/env" ] && . "/Users/syaifulbahri/.ghcup/env" # ghcup-env

if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# if [[ -d "$HOME/.config/kokav" ]]; then
#   export KOKAV_DIR="$HOME/.config/kokav"
#   [ -s "$KOKAV_DIR/kokav.sh" ] && \. "$KOKAV_DIR/kokav.sh" # This loads kokav
# fi

#source "$HOME/.rye/env"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opam configuration
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>/dev/null

# phpenv
if [[ -d "$HOME/.config/phpenv" ]]; then
  export PHPENV_ROOT="$HOME/.config/phpenv"
  export PATH="$HOME/.config/phpenv/bin:$PATH"
  eval "$(phpenv init -)"
fi

[[ $(arch) = "arm64" ]] &&
  eval "$(/opt/homebrew/bin/brew shellenv)" ||
  eval "$(/usr/local/Homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/bin:$HOME/.rvm/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"
