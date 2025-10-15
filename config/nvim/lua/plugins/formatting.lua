return {
  -- Use ESLint for formatting JS/TS files instead of Prettier/vtsls
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      },
    },
  },
  -- Disable vtsls formatting capabilities
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          on_attach = function(client, bufnr)
            -- Disable vtsls formatting to avoid conflicts with ESLint
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            -- Call the custom on_attach from sbahri.lsp
            require("sbahri.lsp").on_attach(client, bufnr)
          end,
        },
      },
    },
  },
}
