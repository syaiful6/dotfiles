return {
  {
    "syaiful6/ocaml.nvim",
    dev = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    opts = function()
      local Lsp = require("sbahri.lsp")

      return {
        lsp = {
          capabilities = Lsp.capabilities(),
          on_attach = Lsp.on_attach,
        },
      }
    end,
    config = function(_, opts)
      vim.g.ocamlnvim = vim.tbl_deep_extend("keep", vim.g.ocamlnvim or {}, opts or {})

      local dap_ok, dap = pcall(require, "dap")
      if dap_ok then
        dap.adapters.ocamlearlybird = {
          type = "executable",
          command = "ocamlearlybird",
          args = { "debug" },
        }

        dap.configurations.ocaml = {
          {
            name = "OCaml Debug",
            type = "ocamlearlybird",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            stopOnEntry = false,
            arguments = function()
              local args_str = vim.fn.input("Arguments: ")
              if args_str == "" then
                return {}
              end
              return vim.split(args_str, " ")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            name = "OCaml Debug (with arguments)",
            type = "ocamlearlybird",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            stopOnEntry = false,
            arguments = function()
              local args_str = vim.fn.input("Arguments: ")
              if args_str == "" then
                return {}
              end
              return vim.split(args_str, " ")
            end,
            cwd = "${workspaceFolder}",
            env = function()
              local variables = {}
              for k, v in pairs(vim.fn.environ()) do
                table.insert(variables, string.format("%s=%s", k, v))
              end
              return variables
            end,
          },
        }
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ocaml", "ocaml_interface", "ocamllex" })
    end,
  },
}
