local Lsp = require("sbahri.lsp")

return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "ml", "mli", "cmi", "cmo", "cmx", "cma", "cmxa", "cmxs", "cmt", "cmti", "opam" },
      root = { "merlin.opam", "dune-project" },
    })
  end,
  {
    "syaiful6/ocaml.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp = {
        capabilities = Lsp.capabilties,
        on_attach = Lsp.on_attach,
      },
    },
    config = function(_, opts)
      vim.g.ocamlnvim = vim.tbl_deep_extend("keep", vim.g.ocamlnvim or {}, opts or {})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = { enable = false },
      },
      setup = {
        -- Make sure lspconfig doesn't start ocamllsp,
        -- as it conflicts with ocaml.nvim
        ocamllsp = function()
          return true
        end,
      },
    },
  },
}
