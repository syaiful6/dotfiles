return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "python", "ninja", "rst" })
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
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
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        keys = {
          { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
          { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class",  ft = "python" },
        },
        config = function()
          local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
          if vim.fn.executable(venv_python) == 1 then
            require("dap-python").setup(venv_python)
          else
            require("dap-python").setup("python3")
          end
        end,
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
  {
    "MeanderingProgrammer/py-requirements.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('py-requirements').setup({})
    end,
  }
}
