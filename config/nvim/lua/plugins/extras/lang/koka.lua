return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, _)
      vim.filetype.add({
        extension = {
          kk = "koka",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        koka = {
          root_dir = function(name)
            return require("lspconfig.util").root_pattern(
                ".git",
                "package.kk",
                "*.kk"
              )(fname)
          end,
        },
      },
    },
  },
}
