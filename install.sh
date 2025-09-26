#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Function to create symlink
create_symlink() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    # If it's already a symlink, check if it's broken
    if [[ ! -e "$target" ]]; then
      echo -e "${YELLOW}Fixing broken symlink: $target${NC}"
      rm "$target"
    elif [[ "$(readlink "$target")" == "$source" ]]; then
      # Already correctly linked
      return 0
    else
      # Different symlink, ask user
      echo -e "${YELLOW}$target is already a symlink to $(readlink "$target")${NC}"
      read -p "Replace it? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
      fi
      rm "$target"
    fi
  elif [[ -e "$target" ]]; then
    # File exists, ask user
    echo -e "${YELLOW}$target already exists${NC}"
    read -p "Replace it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi
    rm "$target"
  fi

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target")"

  # Create symlink
  ln -s "$source" "$target"
  echo -e "${GREEN}Linked: $target -> $source${NC}"
}

# Function to setup gitconfig
setup_gitconfig() {
  local source="$DOTFILES_DIR/gitconfig.tpl"
  local work_source="$DOTFILES_DIR/gitconfig-work.tpl"
  local target="$HOME/.gitconfig"
  local work_target="$HOME/.gitconfig-work"

  if [[ -f "$target" ]]; then
    return 0
  fi

  # Prompt for git configuration
  echo -e "${GREEN}Setting up git configuration...${NC}"

  # Personal profile
  echo -e "${BLUE}Personal profile:${NC}"
  read -p "Enter your full name: " git_name
  read -p "Enter your personal email: " git_email
  read -p "Enter your GitHub username: " github_username

  # Work profile
  echo -e "${BLUE}Work profile (leave empty to skip):${NC}"
  read -p "Enter your work name (or press Enter for same as personal): " work_name
  read -p "Enter your work email (or press Enter to skip): " work_email
  read -p "Enter your work directory path (default: ~/Documents/code/bbx): " work_path

  # Use personal name for work if not provided
  if [[ -z "$work_name" ]]; then
    work_name="$git_name"
  fi

  # Use default work path if not provided
  if [[ -z "$work_path" ]]; then
    work_path="~/Documents/code/bbx"
  fi

  # Create main gitconfig from template
  sed -e "s/YOUR_NAME/$git_name/g" \
    -e "s/YOUR_EMAIL/$git_email/g" \
    -e "s/YOUR_SIGNING_KEY//g" \
    -e "s/YOUR_GITHUB_USERNAME/$github_username/g" \
    -e "s|YOUR_WORK_PATH|$work_path|g" \
    "$source" >"$target"

  # Create work gitconfig if work email provided
  if [[ -n "$work_email" ]]; then
    sed -e "s/YOUR_WORK_NAME/$work_name/g" \
      -e "s/YOUR_WORK_EMAIL/$work_email/g" \
      -e "s/YOUR_WORK_SIGNING_KEY//g" \
      "$work_source" >"$work_target"

    echo -e "${GREEN}Created: $target${NC}"
    echo -e "${GREEN}Created: $work_target${NC}"
    echo -e "${YELLOW}Work profile will be used in: $work_path${NC}"
  else
    echo -e "${GREEN}Created: $target (personal profile only)${NC}"
  fi

  echo -e "${YELLOW}💡 Run 'sbdot gpg generate' to create GPG keys for commit signing${NC}"
}

# Function to check if file should be excluded
should_exclude() {
  local file="$1"

  # Exclude .git directory and its contents
  if [[ "$file" == ".git" ]] || [[ "$file" == .git/* ]]; then
    return 0
  fi

  # Exclude system files
  case "$file" in
  ".DS_Store" | *"/.DS_Store")
    return 0
    ;;
  ".gitkeep" | *"/.gitkeep")
    return 0
    ;;
  esac

  # Exclude specific files
  case "$file" in
  "install.rb" | "install.sh" | ".gitignore" | ".gitmodules" | "CLAUDE.md" | "README.md")
    return 0
    ;;
  *"_extras/"*)
    return 0
    ;;
  "packages/"* | "packages")
    return 0
    ;;
  "bashrc.local")
    return 0
    ;;
  "gitconfig.tpl" | "gitconfig-work.tpl")
    return 0
    ;;
  esac

  return 1
}

# Change to dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Find all files and create symlinks
while IFS= read -r -d '' file; do
  # Remove leading ./ and any remaining leading /
  file="${file#./}"
  file="${file#/}"

  # Skip if should be excluded
  if should_exclude "$file"; then
    continue
  fi

  # Create target path in home directory (add dot prefix)
  target="$HOME/.$file"
  source="$DOTFILES_DIR/$file"

  create_symlink "$source" "$target"
done < <(find . -type f -not -path './.git/*' -print0)

# Create sbdot config directory and symlink packages
mkdir -p "$HOME/.config/sbdot"
if [[ ! -e "$HOME/.config/sbdot/packages" ]]; then
  ln -s "$DOTFILES_DIR/packages" "$HOME/.config/sbdot/packages"
  echo -e "${GREEN}Linked: ~/.config/sbdot/packages -> $DOTFILES_DIR/packages${NC}"
fi

# Function to install oh-my-zsh
install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${YELLOW}oh-my-zsh is already installed${NC}"
    return 0
  fi

  echo -e "${GREEN}Installing oh-my-zsh...${NC}"

  # Check if zsh is installed
  if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}zsh is not installed. Please install zsh first:${NC}"
    echo -e "${YELLOW}  Ubuntu/Debian: sudo apt install zsh${NC}"
    echo -e "${YELLOW}  Arch Linux: sudo pacman -S zsh${NC}"
    echo -e "${YELLOW}  macOS: brew install zsh (if not already installed)${NC}"
    read -p "Continue with oh-my-zsh installation anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi
  fi

  # Install oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # oh-my-zsh installer creates a default .zshrc, but we want to use our own
  # Back up the oh-my-zsh generated .zshrc and restore our symlink
  if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.oh-my-zsh-backup"
    echo -e "${YELLOW}Backed up oh-my-zsh generated .zshrc to ~/.zshrc.oh-my-zsh-backup${NC}"

    # Recreate our zshrc symlink
    if [[ -f "$DOTFILES_DIR/zshrc" ]]; then
      ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
      echo -e "${GREEN}Restored dotfiles zshrc symlink${NC}"
    fi
  fi

  echo -e "${GREEN}oh-my-zsh installation complete!${NC}"

  # Install useful zsh plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Install zsh-autosuggestions
  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo -e "${GREEN}Installing zsh-autosuggestions plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # Install zsh-syntax-highlighting
  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo -e "${GREEN}Installing zsh-syntax-highlighting plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi

  echo -e "${YELLOW}💡 You may want to change your default shell: chsh -s \$(which zsh)${NC}"
}

# Setup gitconfig
setup_gitconfig

# Install oh-my-zsh
install_oh_my_zsh

echo -e "${GREEN}Dotfiles installation complete!${NC}"

