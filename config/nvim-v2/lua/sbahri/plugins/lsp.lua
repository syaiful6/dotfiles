local Lsp = require("sbahri.lsp")
local Helpers = require("sbahri.helpers")

local python_root_dir = Helpers.root_pattern(
  "pyproject.toml",
  "pyrefly.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "pyrightconfig.json",
  ".git"
)

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
      local Python = require("sbahri.python")
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

      vim.lsp.config("ruff", {
        capabilities = capabilities,
        filetypes = { "python" },
        on_attach = function(client, bufnr)
          -- disable hover in favor of pyrefly/basedpyright
          client.server_capabilities.hoverProvider = false
          on_attach(client, bufnr)
        end,
      })
      vim.lsp.enable("ruff")

      vim.lsp.config("pyrefly", {
        cmd = { Python.get_venv_tool("pyrefly") or "pyrefly", "lsp" },
        capabilities = capabilities,
        filetypes = { "python" },
        on_attach = on_attach,
        root_dir = function(bufnr, on_dir)
          if Python.get_venv_tool("pyrefly") ~= nil then
            return on_dir(python_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
      })
      vim.lsp.enable("pyrefly")

      vim.lsp.config("basedpyright", {
        enable = vim.fn.executable("pyrefly") == 0,
        cmd = { "basedpyright-langserver", "--stdio" },
        capabilities = capabilities,
        filetypes = { "python" },
        on_attach = Lsp.on_attach,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
        root_dir = function(bufnr, on_dir)
          if Python.get_venv_tool("pyrefly") == nil then
            return on_dir(python_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
      })
      vim.lsp.enable("basedpyright")

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
