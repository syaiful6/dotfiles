return {
  {
    "mrcjkb/rustaceanvim",
    version = "6^",
    lazy = false,
    ft = { "rust" },
    init = function()
      local Lsp = require("sbahri.lsp")

      vim.g.rustaceanvim = {
        tools = {},
        server = {
          on_attach = Lsp.on_attach,
          capabilities = Lsp.capabilities(),
        },
        dap = {},
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust", "ron" })
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = false },
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
}
