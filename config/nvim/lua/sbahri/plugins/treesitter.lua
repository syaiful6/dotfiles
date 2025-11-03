return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
          max_lines = 1,
        },
      },
    },
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
      -- Only essential parsers to reduce memory usage
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "vim",
        "vimdoc",
        "yaml",
        "ocaml",
        "rust",
      },
      -- Auto-install parsers when opening files
      auto_install = false,
      -- Highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      local group = vim.api.nvim_create_augroup("custom-treesitter", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          local bufnr = args.buf
          local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
          if not ok or not parser then
            return
          end
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

}
