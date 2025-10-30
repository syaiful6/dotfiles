local Lsp = require("sbahri.lsp")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          enabled = true,
          on_attach = Lsp.on_attach,
          capabilities = Lsp.capabilities(),
        },
      },
    },
  },
}
