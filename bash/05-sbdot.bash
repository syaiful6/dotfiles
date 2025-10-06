# SyaifulBahri Dotfiles utility functions
# Usage: sbdot <command> [args...]

# Colors for output
_sbdot_red='\033[0;31m'
_sbdot_green='\033[0;32m'
_sbdot_yellow='\033[1;33m'
_sbdot_blue='\033[0;34m'
_sbdot_nc='\033[0m' # No Color

# Get dotfiles directory
_sbdot_get_dotfiles_dir() {
  # Try to find the directory containing the bash files
  if [[ -n "${BASH_SOURCE[0]}" ]]; then
    dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")"
  elif [[ -d "$HOME/.dotfiles" ]]; then
    echo "$HOME/.dotfiles"
  else
    echo "$HOME"
  fi
}

# Detect operating system
_sbdot_detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ -f /etc/arch-release ]]; then
    echo "arch"
  elif [[ -f /etc/lsb-release ]] && grep -q "Ubuntu" /etc/lsb-release; then
    echo "ubuntu"
  else
    echo "unknown"
  fi
}

# Package management functions
_sbdot_pkg_install() {
  local packages_dir="$HOME/.config/sbdot/packages"
  local os="$(_sbdot_detect_os)"
  local original_dir="$PWD"

  if [[ ! -d "$packages_dir" ]]; then
    echo -e "${_sbdot_red}❌ Package definitions not found. Run ./install.sh first.${_sbdot_nc}"
    return 1
  fi

  echo -e "${_sbdot_blue}🚀 Installing packages for $os...${_sbdot_nc}"

  case "$os" in
  "macos")
    # Install Homebrew if not present
    if ! command -v brew &>/dev/null; then
      echo -e "${_sbdot_yellow}Installing Homebrew...${_sbdot_nc}"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install packages from Brewfile
    if [[ -f "$packages_dir/Brewfile" ]]; then
      (cd "$packages_dir" && brew bundle install)
    fi
    ;;
  "arch")
    # Update package database
    sudo pacman -Sy

    # Install packages from arch-packages.txt
    if [[ -f "$packages_dir/arch-packages.txt" ]]; then
      sudo pacman -S --needed $(grep -v '^#' "$packages_dir/arch-packages.txt" | xargs)
    fi

    # Install yay (AUR helper) if not present
    if ! command -v yay &>/dev/null; then
      echo -e "${_sbdot_yellow}Installing yay (AUR helper)...${_sbdot_nc}"
      (
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
      )
    fi
    ;;
  "ubuntu")
    # Update package lists
    sudo apt update

    # Install packages from ubuntu-packages.txt
    if [[ -f "$packages_dir/ubuntu-packages.txt" ]]; then
      sudo apt install -y $(grep -v '^#' "$packages_dir/ubuntu-packages.txt" | xargs)
    fi
    ;;
  *)
    echo -e "${_sbdot_red}❌ Unsupported operating system: $os${_sbdot_nc}"
    return 1
    ;;
  esac

  # Restore original directory
  cd "$original_dir"
  echo -e "${_sbdot_green}✅ System packages installed${_sbdot_nc}"
}

_sbdot_pkg_lang() {
  echo -e "${_sbdot_yellow}🔧 Installing language toolchains...${_sbdot_nc}"

  # Install Rust via rustup
  if ! command -v rustc &>/dev/null; then
    echo -e "${_sbdot_yellow}Installing Rust (rustup)...${_sbdot_nc}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi

  # Install Node.js via nvm
  if ! command -v node &>/dev/null; then
    echo -e "${_sbdot_yellow}Installing Node.js (nvm)...${_sbdot_nc}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
  fi

  # Install Haskell via ghcup
  if ! command -v ghc &>/dev/null; then
    echo -e "${_sbdot_yellow}Installing Haskell (ghcup)...${_sbdot_nc}"
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  fi

  # install opam
  if ! command -v opam &>/dev/null; then
    echo -e "${_sbdot_yellow}Installing OCaml (opam)...${_sbdot_nc}"
    curl -fsSL https://opam.ocaml.org/install.sh | sh
  fi

  # Use uv to manage python version and projects
  if ! command -v uv &>/dev/null; then
    echo -e "${_sbdot_yellow}Installing uv (Python version manager)...${_sbdot_nc}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

  echo -e "${_sbdot_green}✅ Language toolchains installed${_sbdot_nc}"
}

_sbdot_pkg_list() {
  local packages_dir="$HOME/.config/sbdot/packages"
  local os="$(_sbdot_detect_os)"

  if [[ ! -d "$packages_dir" ]]; then
    echo -e "${_sbdot_red}❌ Package definitions not found. Run ./install.sh first.${_sbdot_nc}"
    return 1
  fi

  echo -e "${_sbdot_blue}📦 Packages for $os:${_sbdot_nc}"

  case "$os" in
  "macos")
    if [[ -f "$packages_dir/Brewfile" ]]; then
      cat "$packages_dir/Brewfile"
    fi
    ;;
  "arch")
    if [[ -f "$packages_dir/arch-packages.txt" ]]; then
      cat "$packages_dir/arch-packages.txt"
    fi
    ;;
  "ubuntu")
    if [[ -f "$packages_dir/ubuntu-packages.txt" ]]; then
      cat "$packages_dir/ubuntu-packages.txt"
    fi
    ;;
  *)
    echo -e "${_sbdot_red}❌ Unsupported operating system: $os${_sbdot_nc}"
    return 1
    ;;
  esac
}

# Clipboard utility function
_sbdot_clipboard_copy() {
  local content="$1"

  # Detect clipboard command
  if command -v pbcopy &>/dev/null; then
    # macOS
    echo "$content" | pbcopy
    echo "Copied to clipboard (pbcopy)"
  elif command -v xclip &>/dev/null; then
    # Linux with xclip
    echo "$content" | xclip -selection clipboard
    echo "Copied to clipboard (xclip)"
  elif command -v xsel &>/dev/null; then
    # Linux with xsel
    echo "$content" | xsel --clipboard --input
    echo "Copied to clipboard (xsel)"
  elif command -v wl-copy &>/dev/null; then
    # Wayland
    echo "$content" | wl-copy
    echo "Copied to clipboard (wl-copy)"
  else
    echo -e "${_sbdot_yellow}⚠️  No clipboard tool found (install xclip, xsel, or wl-clipboard)${_sbdot_nc}"
    return 1
  fi
}

# GPG management functions
_sbdot_gpg_generate() {
  echo -e "${_sbdot_blue}🔐 Generating new GPG key...${_sbdot_nc}"

  # Prompt for user information
  read -p "Enter your full name: " full_name
  read -p "Enter your email address: " email
  read -s -p "Enter passphrase for GPG key: " passphrase
  echo

  # Generate key non-interactively
  cat >/tmp/gpg-batch <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $full_name
Name-Email: $email
Expire-Date: 2y
Passphrase: $passphrase
%commit
%echo GPG key generated successfully
EOF

  gpg --batch --generate-key /tmp/gpg-batch
  rm /tmp/gpg-batch

  echo -e "${_sbdot_green}✅ GPG key generated successfully${_sbdot_nc}"
  _sbdot_gpg_list
}

_sbdot_gpg_list() {
  echo -e "${_sbdot_blue}📋 GPG keys:${_sbdot_nc}"
  gpg --list-secret-keys --keyid-format LONG
}

_sbdot_gpg_backup() {
  local key_selector="$1"
  local backup_dir="$HOME/.gnupg-backup"
  mkdir -p "$backup_dir"

  echo -e "${_sbdot_blue}📤 Backing up GPG keys...${_sbdot_nc}"

  local key_id
  if [[ -z "$key_selector" ]]; then
    # No argument provided, list keys and let user choose
    local keys=($(gpg --list-secret-keys --keyid-format LONG | grep "sec" | sed 's/.*\/\([A-F0-9]*\) .*/\1/'))

    if [[ ${#keys[@]} -eq 0 ]]; then
      echo -e "${_sbdot_red}❌ No GPG keys found to backup${_sbdot_nc}"
      return 1
    elif [[ ${#keys[@]} -eq 1 ]]; then
      # Only one key, use it
      key_id="${keys[0]}"
      echo "Backing up key: $key_id"
    else
      # Multiple keys, show list
      echo "Available GPG keys:"
      for i in "${!keys[@]}"; do
        local kid="${keys[$i]}"
        local email=$(gpg --list-secret-keys --keyid-format LONG | grep -A 1 "$kid" | grep "uid" | sed 's/.*<\([^>]*\)>.*/\1/')
        echo "  $((i + 1)). $kid ($email)"
      done
      echo ""
      printf "Select key to backup (1-${#keys[@]}): "
      read choice

      if [[ "$choice" -ge 1 && "$choice" -le ${#keys[@]} ]]; then
        key_id="${keys[$((choice - 1))]}"
      else
        echo -e "${_sbdot_red}❌ Invalid selection${_sbdot_nc}"
        return 1
      fi
    fi
  else
    # Key ID provided as argument
    key_id="$key_selector"
    # Verify key exists
    if ! gpg --list-secret-keys --keyid-format LONG "$key_id" &>/dev/null; then
      echo -e "${_sbdot_red}❌ Key not found: $key_id${_sbdot_nc}"
      return 1
    fi
    echo "Backing up key: $key_id"
  fi

  # Export keys
  gpg --armor --export "$key_id" >"$backup_dir/public-key-$key_id.asc"
  gpg --armor --export-secret-key "$key_id" >"$backup_dir/private-key-$key_id.asc"
  gpg --export-ownertrust >"$backup_dir/ownertrust.txt"

  # Create compressed backup
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_file="$HOME/gpg-backup-$key_id-$timestamp.tar.gz"
  tar -czf "$backup_file" -C "$HOME" .gnupg-backup

  echo -e "${_sbdot_green}✅ GPG key $key_id backed up to: $backup_file${_sbdot_nc}"
  echo -e "${_sbdot_yellow}⚠️  Store this file securely!${_sbdot_nc}"
}

_sbdot_gpg_restore() {
  local backup_file="$1"

  if [[ -z "$backup_file" ]]; then
    echo "Usage: sbdot gpg restore <backup-file.tar.gz>"
    return 1
  fi

  if [[ ! -f "$backup_file" ]]; then
    echo -e "${_sbdot_red}❌ Backup file not found: $backup_file${_sbdot_nc}"
    return 1
  fi

  echo -e "${_sbdot_blue}📁 Restoring GPG backup...${_sbdot_nc}"

  # Extract and import
  tar -xzf "$backup_file" -C "$HOME"

  local backup_dir="$HOME/.gnupg-backup"
  for key_file in "$backup_dir"/*.asc; do
    if [[ -f "$key_file" ]]; then
      gpg --import "$key_file"
    fi
  done

  if [[ -f "$backup_dir/ownertrust.txt" ]]; then
    gpg --import-ownertrust "$backup_dir/ownertrust.txt"
  fi

  echo -e "${_sbdot_green}✅ GPG keys restored successfully${_sbdot_nc}"
  _sbdot_gpg_list
}

_sbdot_gpg_configure() {
  echo -e "${_sbdot_blue}⚙️  Configuring Git for GPG signing...${_sbdot_nc}"

  local key_id=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | sed 's/.*\/\([A-F0-9]*\) .*/\1/')

  if [[ -z "$key_id" ]]; then
    echo -e "${_sbdot_red}❌ No GPG keys found. Generate or import keys first.${_sbdot_nc}"
    return 1
  fi

  # Configure Git
  git config --global user.signingkey "$key_id"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true

  echo -e "${_sbdot_green}✅ Git configured for GPG signing: $key_id${_sbdot_nc}"
  echo -e "${_sbdot_yellow}📋 Add this public key to GitHub/GitLab:${_sbdot_nc}"
  echo "----------------------------------------"
  local public_key=$(gpg --armor --export "$key_id")
  echo "$public_key"
  echo "----------------------------------------"

  # Copy to clipboard
  _sbdot_clipboard_copy "$public_key"
}

_sbdot_gpg_copy() {
  local key_selector="$1"

  if [[ -z "$key_selector" ]]; then
    # No argument provided, list keys and let user choose
    local keys=($(gpg --list-secret-keys --keyid-format LONG | grep "sec" | sed 's/.*\/\([A-F0-9]*\) .*/\1/'))

    if [[ ${#keys[@]} -eq 0 ]]; then
      echo -e "${_sbdot_red}❌ No GPG keys found${_sbdot_nc}"
      return 1
    elif [[ ${#keys[@]} -eq 1 ]]; then
      # Only one key, use it
      key_selector="${keys[0]}"
    else
      # Multiple keys, show list
      echo "Available GPG keys:"
      for i in "${!keys[@]}"; do
        local key_id="${keys[$i]}"
        local email=$(gpg --list-secret-keys --keyid-format LONG | grep -A 1 "$key_id" | grep "uid" | sed 's/.*<\([^>]*\)>.*/\1/')
        echo "  $((i + 1)). $key_id ($email)"
      done
      echo ""
      printf "Select key to copy (1-${#keys[@]}): "
      read choice

      if [[ "$choice" -ge 1 && "$choice" -le ${#keys[@]} ]]; then
        key_selector="${keys[$((choice - 1))]}"
      else
        echo -e "${_sbdot_red}❌ Invalid selection${_sbdot_nc}"
        return 1
      fi
    fi
  fi

  # Get public key
  local public_key=$(gpg --armor --export "$key_selector" 2>/dev/null)

  if [[ -z "$public_key" ]]; then
    echo -e "${_sbdot_red}❌ Key not found: $key_selector${_sbdot_nc}"
    return 1
  fi

  echo -e "${_sbdot_green}📋 Copying GPG public key: $key_selector${_sbdot_nc}"
  _sbdot_clipboard_copy "$public_key"
}

# Profile management functions
_sbdot_git_status() {
  echo -e "${_sbdot_blue}📋 Git Profile Status:${_sbdot_nc}"
  echo ""

  # Show global config
  echo -e "${_sbdot_yellow}Global (Personal) Profile:${_sbdot_nc}"
  echo "  Name:       $(git config --global user.name)"
  echo "  Email:      $(git config --global user.email)"
  echo "  Signing:    $(git config --global user.signingkey || echo "Not configured")"
  echo ""

  # Show work config if exists
  if [[ -f "$HOME/.gitconfig-work" ]]; then
    echo -e "${_sbdot_yellow}Work Profile:${_sbdot_nc}"
    echo "  Name:       $(git config --file ~/.gitconfig-work user.name)"
    echo "  Email:      $(git config --file ~/.gitconfig-work user.email)"
    echo "  Signing:    $(git config --file ~/.gitconfig-work user.signingkey || echo "Not configured")"
    echo ""

    # Show work directories
    echo -e "${_sbdot_yellow}Work Directories:${_sbdot_nc}"
    grep "gitdir:" "$HOME/.gitconfig" | sed 's/.*gitdir:\([^]]*\)].*/  \1/' | sed 's/~/$HOME/g'
  else
    echo -e "${_sbdot_yellow}No work profile configured${_sbdot_nc}"
  fi
  echo ""

  # Show current directory profile
  if git rev-parse --git-dir &>/dev/null; then
    echo -e "${_sbdot_yellow}Current Repository Profile:${_sbdot_nc}"
    echo "  Name:       $(git config user.name)"
    echo "  Email:      $(git config user.email)"
    echo "  Signing:    $(git config user.signingkey || echo "Not configured")"
  fi
}

_sbdot_git_configure_keys() {
  echo -e "${_sbdot_blue}🔐 Configuring GPG keys for Git profiles...${_sbdot_nc}"

  # List available keys
  local keys=($(gpg --list-secret-keys --keyid-format LONG | grep "sec" | sed 's/.*\/\([A-F0-9]*\) .*/\1/'))

  if [[ ${#keys[@]} -eq 0 ]]; then
    echo -e "${_sbdot_red}❌ No GPG keys found. Generate keys first with 'sbdot gpg generate'${_sbdot_nc}"
    return 1
  fi

  echo "Available GPG keys:"
  for i in "${!keys[@]}"; do
    local key_id="${keys[$i]}"
    local email=$(gpg --list-secret-keys --keyid-format LONG | grep -A 1 "$key_id" | grep "uid" | sed 's/.*<\([^>]*\)>.*/\1/')
    echo "  $((i + 1)). $key_id ($email)"
  done
  echo ""

  # Configure personal key
  read -p "Select personal key (1-${#keys[@]}): " personal_choice
  if [[ "$personal_choice" -ge 1 && "$personal_choice" -le ${#keys[@]} ]]; then
    local personal_key="${keys[$((personal_choice - 1))]}"
    git config --global user.signingkey "$personal_key"
    echo -e "${_sbdot_green}✅ Personal profile configured with key: $personal_key${_sbdot_nc}"
  fi

  # Configure work key if work profile exists
  if [[ -f "$HOME/.gitconfig-work" ]]; then
    echo ""
    read -p "Select work key (1-${#keys[@]}, or Enter to skip): " work_choice
    if [[ "$work_choice" -ge 1 && "$work_choice" -le ${#keys[@]} ]]; then
      local work_key="${keys[$((work_choice - 1))]}"
      git config --file ~/.gitconfig-work user.signingkey "$work_key"
      echo -e "${_sbdot_green}✅ Work profile configured with key: $work_key${_sbdot_nc}"
    fi
  fi
}

_sbdot_git_generate_profile() {
  local profile="$1"
  if [[ "$profile" != "personal" && "$profile" != "work" ]]; then
    echo "Usage: sbdot git generate <personal|work>"
    return 1
  fi

  echo -e "${_sbdot_blue}🔐 Generating GPG key for $profile profile...${_sbdot_nc}"

  # Get email for this profile
  local email
  if [[ "$profile" == "personal" ]]; then
    email=$(git config --global user.email 2>/dev/null)
  else
    email=$(git config --file ~/.gitconfig-work user.email 2>/dev/null)
  fi

  # Get user input
  if [[ -z "$email" ]]; then
    printf "Enter email for $profile profile: "
    read email
  else
    echo "Using email: $email"
  fi

  printf "Enter your full name: "
  read full_name

  printf "Enter passphrase for GPG key: "
  read -s passphrase
  echo

  # Validate inputs
  if [[ -z "$email" || -z "$full_name" || -z "$passphrase" ]]; then
    echo -e "${_sbdot_red}❌ All fields are required${_sbdot_nc}"
    return 1
  fi

  # Generate key batch file
  local batch_file="/tmp/gpg-batch-$$"
  cat >"$batch_file" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA  
Subkey-Length: 4096
Name-Real: $full_name
Name-Email: $email
Expire-Date: 2y
Passphrase: $passphrase
%commit
%echo GPG key generated successfully
EOF

  echo "Generating GPG key... (this may take a moment)"
  if ! gpg --batch --generate-key "$batch_file"; then
    echo -e "${_sbdot_red}❌ Failed to generate GPG key${_sbdot_nc}"
    rm -f "$batch_file"
    return 1
  fi

  rm -f "$batch_file"

  # Get the new key ID and configure git
  sleep 2 # Give GPG time to update keyring
  local key_id=$(gpg --list-secret-keys --keyid-format LONG "$email" | grep "sec" | head -1 | sed 's/.*\/\([A-F0-9]*\) .*/\1/')

  if [[ -z "$key_id" ]]; then
    echo -e "${_sbdot_red}❌ Failed to find generated key${_sbdot_nc}"
    return 1
  fi

  # Configure git
  if [[ "$profile" == "personal" ]]; then
    git config --global user.signingkey "$key_id"
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
  else
    git config --file ~/.gitconfig-work user.signingkey "$key_id"
  fi

  echo -e "${_sbdot_green}✅ GPG key generated and configured for $profile profile: $key_id${_sbdot_nc}"
  echo -e "${_sbdot_yellow}📋 Add this public key to your GitHub/GitLab account:${_sbdot_nc}"
  echo "----------------------------------------"
  local public_key=$(gpg --armor --export "$key_id")
  echo "$public_key"
  echo "----------------------------------------"

  # Copy to clipboard
  _sbdot_clipboard_copy "$public_key"
}

# Main sbdot function
sbdot() {
  case "$1" in
  "pkg")
    case "$2" in
    "install")
      _sbdot_pkg_install
      _sbdot_pkg_lang
      ;;
    "system")
      _sbdot_pkg_install
      ;;
    "lang")
      _sbdot_pkg_lang
      ;;
    "list")
      _sbdot_pkg_list
      ;;
    *)
      echo "Usage: sbdot pkg <install|system|lang|list>"
      ;;
    esac
    ;;
  "gpg")
    case "$2" in
    "generate")
      _sbdot_gpg_generate
      ;;
    "list")
      _sbdot_gpg_list
      ;;
    "backup")
      _sbdot_gpg_backup "$3"
      ;;
    "restore")
      _sbdot_gpg_restore "$3"
      ;;
    "configure")
      _sbdot_gpg_configure
      ;;
    "copy")
      _sbdot_gpg_copy "$3"
      ;;
    *)
      echo "Usage: sbdot gpg <generate|list|backup|restore|configure|copy>"
      ;;
    esac
    ;;
  "git")
    case "$2" in
    "status")
      _sbdot_git_status
      ;;
    "keys")
      _sbdot_git_configure_keys
      ;;
    "generate")
      _sbdot_git_generate_profile "$3"
      ;;
    *)
      echo "Usage: sbdot git <status|keys|generate>"
      ;;
    esac
    ;;
  "help" | "--help" | "-h" | "")
    echo -e "${_sbdot_blue}SyaifulBahri Dotfiles Utility${_sbdot_nc}"
    echo ""
    echo "Usage: sbdot <command> [args...]"
    echo ""
    echo "Package Management:"
    echo "  pkg install    Install system packages and language toolchains"
    echo "  pkg system     Install only system packages"
    echo "  pkg lang       Install only language toolchains"
    echo "  pkg list       Show packages for current OS"
    echo ""
    echo "GPG Management:"
    echo "  gpg generate   Generate new GPG key"
    echo "  gpg list       List existing GPG keys"
    echo "  gpg copy       Copy GPG public key to clipboard"
    echo "  gpg backup     Backup GPG keys (optionally specify key ID)"
    echo "  gpg restore    Restore GPG keys from backup"
    echo "  gpg configure  Configure Git for GPG signing"
    echo ""
    echo "Git Profile Management:"
    echo "  git status     Show current git profiles and configurations"
    echo "  git keys       Configure GPG keys for personal/work profiles"
    echo "  git generate   Generate GPG key for specific profile (personal|work)"
    echo ""
    echo "Other:"
    echo "  help           Show this help message"
    ;;
  *)
    echo "Unknown command: $1"
    echo "Run 'sbdot help' for usage information"
    return 1
    ;;
  esac
}
