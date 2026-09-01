return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
          max_lines = 1,
        },
      },
    },
    build = ":TSUpdate",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
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
      auto_install = false,
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
      local ts = require("nvim-treesitter")
      ts.setup(opts)

      -- parsers we only want on disk once we actually open a matching
      -- file, rather than installed eagerly on every machine
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "gotmpl", "htmldjango" },
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if vim.list_contains(ts.get_installed("parsers"), ft) then
            pcall(vim.treesitter.start, args.buf, ft)
            return
          end
          ts.install({ ft }):await(function(err)
            if not err then
              vim.schedule(function()
                pcall(vim.treesitter.start, args.buf, ft)
              end)
            end
          end)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

}
