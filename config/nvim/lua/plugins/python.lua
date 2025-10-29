local Lsp = require("sbahri.lsp")
local Python = require("sbahri.python")

if lazyvim_docs then
  -- LSP Server to use for Python.
  -- Options: "pyrefly", "pylsp", "pyright", "basedpyright"
  -- pyrefly is Meta's fast Python language server, fallback to pylsp
  vim.g.lazyvim_python_lsp = "pyrefly"
  -- Set to "ruff_lsp" to use the old LSP implementation version.
  vim.g.lazyvim_python_ruff = "ruff"
end

-- Function to check if pyrefly is available, fallback to pylsp
local function get_python_lsp()
  local lsp_preference = vim.g.lazyvim_python_lsp or "pyrefly"

  if lsp_preference == "pyrefly" then
    -- Check if pyrefly is available
    if vim.fn.executable("pyrefly") == 1 then
      return "pyrefly"
    end

    return "pylsp"
  end

  return lsp_preference
end

local ruff = vim.g.lazyvim_python_ruff or "ruff"

return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = "python",
      root = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
      },
    })
  end,
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyrefly = {
          capabilities = Lsp.capabilities,
          on_attach = Lsp.on_attach,
        },
        pylsp = {
          capabilities = Lsp.capabilities,
          on_attach = Lsp.on_attach,
          settings = {
            pylsp = {
              plugins = {
                django = { enabled = true },
                rope_completion = { enabled = true },
                rope_autoimport = { enabled = true },
                pylint = { enabled = true },
                mypy = { enabled = true },
                black = { enabled = true },
                isort = { enabled = true },
                -- Disable conflicting plugins when using ruff
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
              },
            },
          },
        },
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          capabilities = Lsp.capabilities,
          on_attach = Lsp.on_attach,
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
            },
          },
        },
        ruff_lsp = {
          keys = {
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
            },
          },
        },
      },
      setup = {
        [ruff] = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            -- Disable hover in favor of pylsp
            client.server_capabilities.hoverProvider = false
          end, ruff)
        end,
        pyrefly = function()
          local command = Python.get_venv_tool("pyrefly")
          if vim.lsp.config.pyrefly and command then
            vim.lsp.config("pyrefly", {
              cmd = { command, "lsp" },
            })
          end
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lsp = get_python_lsp()
      local servers = { "pyrefly", "pyright", "basedpyright", "pylsp", "ruff" }
      for _, server in ipairs(servers) do
        opts.servers[server] = opts.servers[server] or {}
        opts.servers[server].enabled = server == lsp or server == ruff
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = ".venv/bin/python",
          args = { "--tb=short", "-v" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
        { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class",  ft = "python" },
      },
      config = function()
        -- First try to use project's .venv, fallback to system debugpy
        local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv_python) == 1 then
          require("dap-python").setup(venv_python)
        elseif vim.fn.has("win32") == 1 then
          require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
        else
          require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
        end
      end,
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = false,
        },
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },

  -- Don't mess up DAP adapters provided by nvim-dap-python
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
}
