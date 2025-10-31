return {
  {
    "syaiful6/ocaml.nvim",
    ft = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocamllex", "opam" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
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

      local ok, language_processors = pcall(require, "sbahri.blink.language_processors")
      if ok then
        local ocaml_processor = require("sbahri.blink.processors.ocaml")
        language_processors.register({ "ocaml", "ocaml.menhir", "ocaml.interface", "ocamllex" }, ocaml_processor)
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
