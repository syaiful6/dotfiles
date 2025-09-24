return {
  {
    "syaiful6/koka.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    config = function(_, opts)
      -- copy opts to kokanvim global
      vim.g.kokanvim = vim.tbl_deep_extend("keep", vim.g.kokanvim or {}, opts or {})
      -- setup custom keymaps, (optional)
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
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        koka = false,
      },
    },
  },
}
