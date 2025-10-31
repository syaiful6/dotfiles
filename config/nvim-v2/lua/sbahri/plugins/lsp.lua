local Lsp = require("sbahri.lsp")

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = true,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "bashls",
            "jsonls",
          },
        },
      },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "rachartier/tiny-code-action.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "LspAttach",
        opts = {
          backend = "vim",
          picker = "snacks",
        },
      },
    },
    config = function()
      local capabilities = Lsp.capabilities()
      local on_attach = Lsp.on_attach

      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        root_markers = { ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("bashls")

      vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        root_markers = { ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("jsonls")

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("ts_ls")

      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("gopls")

      vim.lsp.config("cssls", {
        cmd = { "vscode-css-language-server", "--stdio" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("cssls")

      vim.lsp.config("html", {
        cmd = { "vscode-html-language-server", "--stdio" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("html")

      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })
    end,
  },
}
