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
        "$source" > "$target"
    
    # Create work gitconfig if work email provided
    if [[ -n "$work_email" ]]; then
        sed -e "s/YOUR_WORK_NAME/$work_name/g" \
            -e "s/YOUR_WORK_EMAIL/$work_email/g" \
            -e "s/YOUR_WORK_SIGNING_KEY//g" \
            "$work_source" > "$work_target"
        
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
        ".DS_Store"|*"/.DS_Store")
            return 0
            ;;
        ".gitkeep"|*"/.gitkeep")
            return 0
            ;;
    esac
    
    # Exclude specific files
    case "$file" in
        "install.rb"|"install.sh"|".gitignore"|".gitmodules"|"CLAUDE.md"|"README.md")
            return 0
            ;;
        *"_extras/"*)
            return 0
            ;;
        "packages/"*|"packages")
            return 0
            ;;
        "bashrc.local")
            return 0
            ;;
        "gitconfig.tpl"|"gitconfig-work.tpl")
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

# Setup gitconfig
setup_gitconfig

echo -e "${GREEN}Dotfiles installation complete!${NC}"