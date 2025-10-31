return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "python", "ninja", "rst" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local Lsp = require("sbahri.lsp")
      local Python = require("sbahri.python")

      opts.servers = opts.servers or {}

      opts.servers.ruff = {
        cmd_env = { RUFF_TRACE = "messages" },
        capabilities = Lsp.capabilities(),
        on_attach = function(client, bufnr)
          -- Disable hover in favor of pyrefly/basedpyright
          client.server_capabilities.hoverProvider = false
          Lsp.on_attach(client, bufnr)
        end,
        init_options = {
          settings = {
            logLevel = "error",
          },
        },
      }

      -- Pyrefly (Meta's fast Python LSP) - primary choice
      opts.servers.pyrefly = {
        enabled = vim.fn.executable("pyrefly") == 1,
        capabilities = Lsp.capabilities(),
        on_attach = Lsp.on_attach,
      }

      -- basedpyright - fallback if pyrefly not available
      opts.servers.basedpyright = {
        enabled = vim.fn.executable("pyrefly") == 0,
        capabilities = Lsp.capabilities(),
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
      }

      opts.setup = opts.setup or {}
      opts.setup.pyrefly = function()
        local command = Python.get_venv_tool("pyrefly")
        if command then
          require("lspconfig").pyrefly.setup({
            cmd = { command, "lsp" },
            capabilities = Lsp.capabilities(),
            on_attach = Lsp.on_attach,
          })
          return true
        end
      end

      return opts
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    ft = "python",
    cmd = "VenvSelect",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = false,
        },
      },
    },
  },
}
