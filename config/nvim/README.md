# Minimal Neovim Configuration

A lightweight, performant Neovim configuration optimized for Raspberry Pi and resource-constrained environments.

## Why This Config?

LazyVim is excellent but includes 40+ plugins that can be slow on Raspberry Pi due to:
- Heavy plugin startup overhead
- Multiple language servers running simultaneously
- Resource-intensive UI components
- Treesitter real-time parsing overhead
- Dashboard and statusline plugins

This minimal config provides essential functionality with significantly better performance.

## Features

### Core Functionality
- **LSP**: Language server protocol support with nvim-lspconfig
- **Completion**: Fast completion with blink.cmp (pre-built binaries)
- **Formatting**: Code formatting with conform.nvim
- **Linting**: Linting with nvim-lint
- **Treesitter**: Syntax highlighting (lazy-loaded, with file size limits)
- **File Navigation**: Snacks.nvim picker (optimized settings)

### OCaml Support
Custom completion processor that enhances OCaml development:
- Constructor argument placeholders
- Record field snippets
- Labeled argument completion
- Based on Zed editor's OCaml extension

## Structure

```
nvim-v2/
├── init.lua                          # Entry point
├── lua/
│   └── sbahri/
│       ├── options.lua               # Vim options
│       ├── keymaps.lua               # Key mappings
│       ├── lsp.lua                   # LSP utilities
│       ├── blink/
│       │   ├── language_processors.lua  # Processor registry
│       │   ├── lsp_source.lua          # Custom LSP source
│       │   └── processors/
│       │       └── ocaml.lua           # OCaml processor
│       └── plugins/
│           ├── lsp.lua               # LSP configuration
│           ├── blink.lua             # Completion
│           ├── conform.lua           # Formatting
│           ├── lint.lua              # Linting
│           ├── treesitter.lua        # Syntax highlighting
│           ├── ui.lua                # Snacks.nvim (picker, etc.)
│           ├── devicons.lua          # File icons
│           └── colorscheme.lua       # Color scheme
```

## Performance Optimizations

1. **Lazy Loading**: Plugins load only when needed
2. **Disabled RTP Plugins**: Removes unnecessary built-in plugins
3. **File Size Limits**: Treesitter disabled for files >100KB
4. **Bigfile Detection**: Reduced features for files >1MB
5. **Minimal Parsers**: Only essential treesitter parsers installed
6. **No Frecency**: Disabled expensive file ranking algorithms
7. **Pre-built Binaries**: blink.cmp uses release binaries (no compilation)

## Key Mappings

### Leader Key
- Leader: `<Space>`

### LSP
- `K` - Hover documentation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find references
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>f` - Format buffer
- `<C-k>` - Signature help

### File Navigation
- `<leader>ff` - Find files
- `<leader>fr` - Find recent files
- `<leader>fg` - Live grep
- `<leader>fd` - Show diagnostics
- `<leader>fb` - List buffers
- `<leader>sw` - Search word under cursor

### Buffer Management
- `<S-h>` - Previous buffer
- `<S-l>` - Next buffer
- `<leader>bd` - Delete buffer

### Window Management
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<leader>se` - Equal split sizes
- `<leader>sx` - Close split

### Diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic error

## LSP Servers

Configured servers (install as needed):
- `lua_ls` - Lua
- `bashls` - Bash
- `jsonls` - JSON
- `tsserver` - TypeScript/JavaScript
- `pyright` - Python
- `gopls` - Go
- `ocamllsp` - OCaml
- `cssls` - CSS
- `html` - HTML

Install with Mason:
```vim
:Mason
```

## Formatters

Configure per-filetype in `lua/sbahri/plugins/conform.lua`:
- Lua: stylua
- JavaScript/TypeScript: eslint_d
- Python: black, isort
- Go: gofmt, goimports
- Rust: rustfmt
- OCaml: ocamlformat
- Bash: shfmt

Toggle format-on-save:
```vim
:FormatDisable     " Disable for current buffer
:FormatDisable!    " Disable globally
:FormatEnable      " Re-enable
```

## Linters

Configure per-filetype in `lua/sbahri/plugins/lint.lua`:
- Bash: shellcheck
- JavaScript/TypeScript: eslint
- Python: pylint
- Lua: luacheck
- Markdown: markdownlint

## Installation

1. Backup existing config:
```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

2. Symlink this config:
```bash
ln -s /path/to/dotfiles/config/nvim-v2 ~/.config/nvim
```

3. Start Neovim (plugins install automatically):
```bash
nvim
```

4. Install LSP servers:
```vim
:Mason
```

## Customization

### Add Language Support

1. Add LSP server in `lua/sbahri/plugins/lsp.lua`
2. Add formatter in `lua/sbahri/plugins/conform.lua`
3. Add linter in `lua/sbahri/plugins/lint.lua`
4. Add treesitter parser in `lua/sbahri/plugins/treesitter.lua`

### Create Language Processor

See `lua/sbahri/blink/processors/ocaml.lua` as an example. Create your processor and register it in `lua/sbahri/plugins/blink.lua`.

## Troubleshooting

### Slow Startup
- Check `:Lazy profile` to see plugin load times
- Disable unused language servers in LSP config
- Remove unused treesitter parsers

### Completion Not Working
- Ensure blink.cmp is installed: `:Lazy`
- Check LSP is attached: `:LspInfo`
- Verify capabilities in LSP config

### Formatting Issues
- Check formatter is installed: `:ConformInfo`
- Install formatters: `npm i -g eslint_d`, `pip install black`, etc.

## Comparison to LazyVim

| Feature | LazyVim | This Config |
|---------|---------|-------------|
| Plugins | 40+ | ~10 |
| Startup | ~200ms | ~50ms |
| Memory | ~150MB | ~50MB |
| Complexity | High | Low |
| Customization | Framework-based | Direct |

## License

MIT - Use and modify as needed.
