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

local clangd_root_dir = Helpers.root_pattern(
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.json",
  "configure.ac",
  ".git"
)

--- Swift sourcekit can also handle c/c++ files, we want to use it
--- when we actually are in a swift project
local swift_root_dir = Helpers.root_pattern(
  "Package.swift",
  "swift.config",
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

      vim.lsp.config("vtsls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literal" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = true },
            },
          }
        }
      })
      vim.lsp.enable("vtsls")
      -- disable all ts servers to use vtsls only
      vim.lsp.enable("tsserver", false)
      vim.lsp.enable("ts_ls", false)

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
          if Python.get_venv_tool("pyrefly") ~= nil or vim.fn.executable("pyrefly") == 1 then
            return on_dir(python_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
        on_exit = vim.schedule_wrap(function(code, _, _)
          vim.notify(
            "Closing Pyrefly LSP exited with code" .. code,
            vim.log.levels.INFO,
            { title = "LSP: pyrefly" }
          )
        end),
      })
      vim.lsp.enable("pyrefly")

      vim.lsp.config("basedpyright", {
        cmd = { Python.get_venv_tool("basedpyright-langserver") or "basedpyright-langserver", "--stdio" },
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
          if (Python.get_venv_tool("pyrefly") == nil or vim.fn.executable("pyrefly") ~= 1)
              and (Python.get_venv_tool("basedpyright-langserver") ~= nil
                or vim.fn.executable("basedpyright-langserver") == 1) then
            on_dir(python_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
      })
      vim.lsp.enable("basedpyright")

      -- C/C++ LSP
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = function(bufnr, on_dir)
          if not vim.fs.find("Package.swift", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1] then
            return on_dir(clangd_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
      })
      vim.lsp.enable("clangd")

      vim.lsp.config("sourcekit", {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = function(bufnr, on_dir)
          if vim.fs.find("Package.swift", { path = vim.api.nvim_buf_get_name(bufnr), upward = true })[1] then
            return on_dir(swift_root_dir(vim.api.nvim_buf_get_name(bufnr)))
          end
        end,
      })
      vim.lsp.enable("sourcekit")

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
