-- Colorscheme configuration
return {
  {
    "catppuccin/nvim",
    dependencies = { "bjarneo/aether.nvim" },
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      -- require("hackerman").setup(opts)
      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
}
