return {
  {
    "syaiful6/koka.nvim",
    ft = { "koka" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      local Lsp = require("sbahri.lsp")

      return {
        lsp = {
          on_attach = Lsp.on_attach,
          capabilities = Lsp.capabilities(),
        },
      }
    end,
    config = function(_, opts)
      -- Copy opts to kokanvim global
      vim.g.kokanvim = vim.tbl_deep_extend("keep", vim.g.kokanvim or {}, opts or {})

      -- Setup custom keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "koka",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "<leader>kr", ":KokaRun<CR>", { buffer = buf, desc = "Run Koka function at cursor" })
          vim.keymap.set("n", "<leader>kb", ":KokaBuild<CR>", { buffer = buf, desc = "Build Koka program" })
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "koka" })
    end,
  },
}
