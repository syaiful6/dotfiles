return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "php", "phpdoc" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local Lsp = require("sbahri.lsp")

      opts.servers = opts.servers or {}

      -- Intelephense - popular PHP language server (requires license for premium features)
      opts.servers.intelephense = {
        capabilities = Lsp.capabilities(),
        on_attach = Lsp.on_attach,
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000,
            },
          },
        },
      }

      return opts
    end,
  },
}
