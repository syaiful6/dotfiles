return {
  -- Use ESLint for formatting JS/TS files instead of Prettier/vtsls
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        php = { "php_cs_fixer" },
      },
    },
  },
  -- Disable vtsls formatting capabilities
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            require("sbahri.lsp").on_attach(client, bufnr)
          end,
        },
        vtsls = {
          on_attach = function(client, bufnr)
            -- Disable vtsls formatting to avoid conflicts with ESLint
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            require("sbahri.lsp").on_attach(client, bufnr)
          end,
        },
      },
    },
  },
}
