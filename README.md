# 🏠 SyaifulBahri's Dotfiles

Personal dotfiles with cross-platform package management, automatic Git profile switching, and comprehensive toolchain setup for macOS, Arch Linux, and Ubuntu.

## ✨ Features

- 🔧 **Cross-platform package management** (macOS/Arch/Ubuntu)
- 🔀 **Automatic Git profile switching** (personal/work)
- 🔐 **GPG key management** for commit signing
- 📦 **Language toolchain installation** (Rust, Node.js, Haskell, OCaml)
- ⚡ **Unified `sbdot` command** for all operations
- 🎨 **Neovim with LazyVim** configuration
- 📱 **Tmux** and **Ghostty** terminal setup

## 🚀 Quick Start (New Machine)

```bash
# 1. Clone repository
git clone https://github.com/syaiful6/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Install dotfiles (creates symlinks)
./install.sh

# 3. Reload shell to enable sbdot command
source ~/.bashrc  # or restart terminal

# 4. Install packages and tools
sbdot pkg install

# 5. Set up GPG keys for Git signing
sbdot git generate personal    # Generate personal GPG key
sbdot git generate work        # Generate work GPG key (optional)
```

## 📋 Installation Steps (Detailed)

### Step 1: Install Dotfiles
```bash
./install.sh
```
This will:
- Create symlinks for all config files to your home directory
- Prompt for Git configuration (personal + work profiles)
- Set up automatic profile switching based on directory

### Step 2: Install Packages
```bash
# Install everything (system packages + language tools)
sbdot pkg install

# Or install separately:
sbdot pkg system    # Only system packages (git, neovim, tmux, etc.)
sbdot pkg lang      # Only language toolchains (Rust, Node.js, etc.)
```

### Step 3: Configure GPG Keys
```bash
# Generate keys for commit signing
sbdot git generate personal     # For personal repositories
sbdot git generate work         # For work repositories (optional)

# Or use existing keys
sbdot git keys                  # Assign existing GPG keys to profiles

# Check configuration
sbdot git status               # Show current Git profiles
```

### Step 4: Add GPG Keys to GitHub/GitLab
After generating keys, the public key is automatically copied to your clipboard for easy pasting:
- **GitHub**: Settings → SSH and GPG keys → New GPG key → Paste
- **GitLab**: Preferences → GPG Keys → Add key → Paste

You can also manually copy keys later:
```bash
sbdot gpg copy        # Copy key to clipboard (auto-selects if only one key)
sbdot gpg copy KEY_ID # Copy specific key by ID
```

## 🔧 sbdot Command Reference

### Package Management
```bash
sbdot pkg install     # Install all packages and toolchains
sbdot pkg system      # Install only system packages
sbdot pkg lang        # Install only language toolchains
sbdot pkg list        # Show packages for current OS
```

### GPG Management
```bash
sbdot gpg generate    # Generate new GPG key (interactive)
sbdot gpg list        # List existing GPG keys
sbdot gpg copy        # Copy GPG public key to clipboard
sbdot gpg backup      # Backup keys to secure archive
sbdot gpg restore     # Restore keys from backup
sbdot gpg configure   # Configure Git for GPG signing
```

### Git Profile Management
```bash
sbdot git status      # Show current profile configurations
sbdot git keys        # Assign GPG keys to profiles
sbdot git generate    # Generate profile-specific GPG keys
```

## 🎯 Git Profile Switching

The system automatically switches between personal and work Git profiles based on directory location:

- **Personal Profile**: Used everywhere by default
- **Work Profile**: Automatically activates in work directories (e.g., `~/Documents/code/bbx`)

Each profile can have:
- Different name and email
- Separate GPG signing keys
- Automatic activation based on location

## 📁 Directory Structure

```
dotfiles/
├── bash/                    # Modular bash configuration
│   ├── 01-aliases.bash     # Command aliases
│   ├── 03-function.bash    # Custom shell functions
│   ├── 04-configure.bash   # Shell settings
│   └── 05-sbdot.bash       # sbdot command system
├── config/                  # Application configurations
│   ├── nvim/               # Neovim (LazyVim setup)
│   ├── tmux/               # Terminal multiplexer
│   └── ghostty/            # Terminal emulator
├── packages/               # Package manifests
│   ├── Brewfile            # macOS packages (Homebrew)
│   ├── arch-packages.txt   # Arch Linux packages
│   └── ubuntu-packages.txt # Ubuntu packages
├── gitconfig.tpl           # Git configuration template
├── gitconfig-work.tpl      # Work profile template
├── install.sh              # Dotfiles installer
└── README.md               # This file
```

## 🔗 Symlink Strategy

This dotfiles repository uses **individual file symlinking** instead of whole-directory symlinks (like GNU Stow). This approach has unique advantages:

### How It Works
```bash
# install.sh creates symlinks for individual files:
dotfiles/bashrc        → ~/.bashrc
dotfiles/config/nvim/init.lua → ~/.config/nvim/init.lua
```

### Key Benefits

**✅ Mix Repo Files + Machine-Specific Files**
```
~/.config/nvim/
├── init.lua           # Symlink to repo (version controlled)
├── lua/
│   ├── config.lua     # Symlink to repo (version controlled)
│   └── local.lua      # Local file (machine-specific, not in repo)
└── lazy-lock.json     # Local file (gitignored)
```

**✅ No Directory Ownership Conflicts**
- Entire `~/.config/` directory isn't "owned" by dotfiles
- Other applications can add their own configs to `~/.config/`
- You can create machine-specific files alongside repo files

**✅ Selective Version Control**
- Choose exactly which files to track in git
- Local experiments won't clutter the repo
- Easy to test changes before committing

### Comparison to GNU Stow

| Feature | This Approach | GNU Stow |
|---------|---------------|----------|
| Symlink level | Individual files | Whole directories |
| Mix repo + local files | ✅ Yes | ❌ No (directory is symlinked) |
| Machine-specific configs | Easy to add | Need separate stow package |
| Setup complexity | Simple script | Need stow installed |

### Best Practices

1. **Machine-specific configs**: Create files directly in `~/.config/app/` without adding to repo
2. **Shared configs**: Add to dotfiles repo, `install.sh` will symlink them
3. **Gitignore patterns**: Use `.gitignore` to exclude machine-specific files from repo

**Example workflow:**
```bash
# Create machine-specific Neovim config
echo "vim.g.local_setting = true" > ~/.config/nvim/lua/local-machine.lua

# This file lives alongside symlinked files but isn't tracked in git
# Your dotfiles repo stays clean!
```

## 🔄 Common Workflows

### New Machine Setup
```bash
# Full setup
./install.sh && source ~/.bashrc && sbdot pkg install

# Generate GPG keys
sbdot git generate personal
sbdot git generate work  # if needed

# Add keys to GitHub/GitLab accounts
```

### Adding New Packages
```bash
# Edit package manifest for your OS
vim packages/Brewfile              # macOS
vim packages/arch-packages.txt     # Arch Linux
vim packages/ubuntu-packages.txt   # Ubuntu

# Install new packages
sbdot pkg install
```

### GPG Key Backup (Before Switching Machines)
```bash
# Backup keys
sbdot gpg backup

# Store the generated .tar.gz file securely
# (password manager, encrypted drive, etc.)
```

### GPG Key Restore (On New Machine)
```bash
# Restore from backup
sbdot gpg restore /path/to/backup-file.tar.gz

# Configure Git profiles
sbdot git keys
```

### Checking Git Profile Status
```bash
# See which profile is active
sbdot git status

# Test in different directories
cd ~/Documents/code/prj && sbdot git status    # Personal profile
cd ~/Documents/code/bbx && sbdot git status    # Work profile
```

## 🛠 Package Lists

### Core Packages (All Platforms)
- **Development**: git, neovim, tmux
- **CLI Tools**: ripgrep, fd, bat, fzf, jq, htop
- **Build Tools**: make, cmake, pkg-config
- **Security**: gnupg, pinentry
- **Clipboard**: xclip (Linux), pbcopy (macOS built-in)

### Language Toolchains (Auto-installed)
- **Rust**: via rustup
- **Node.js**: via nvm (latest LTS)
- **Haskell**: via ghcup
- **OCaml**: via opam

## 🔍 Troubleshooting

### sbdot command not found
```bash
# Reload shell configuration
source ~/.bashrc
# or restart your terminal
```

### GPG signing not working
```bash
# Check GPG keys
sbdot gpg list

# Check Git configuration
sbdot git status

# Reconfigure keys
sbdot git keys
```

### Work profile not activating
```bash
# Check conditional includes in ~/.gitconfig
grep -A 2 "includeIf" ~/.gitconfig

# Test profile in work directory
cd ~/Documents/code/bbx
git config user.email  # Should show work email
```

## 📝 Notes

- Work profile setup is optional during installation
- GPG keys are stored securely in `~/.gnupg`
- Backup files contain both public and private keys
- Directory paths are configurable per machine during setup
- All configurations use symlinks for easy updates

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own use!