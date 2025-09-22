local ocaml_ft = {
  "dune",
  "ocaml",
  "ocaml.cram",
  "ocaml.interface",
  "ocaml.menhir",
  "ocaml.mlx",
  "ocaml.ocamllex",
  "opam",
  "reason"
}

return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "ml", "mli", "cmi", "cmo", "cmx", "cma", "cmxa", "cmxs", "cmt", "cmti", "opam" },
      root = { "merlin.opam", "dune-project" },
    })
  end,
  {
    "ocaml/vim-ocaml",
    ft = ocaml_ft,
  },
  {
    "syaiful6/ocaml.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    config = function(_, opts)
      vim.g.ocamlnvim = vim.tbl_deep_extend("keep", vim.g.ocamlnvim or {}, opts or {})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {
          mason = false,
          autostart = false, -- start via ocamlnvim
        },
      },
    },
  },
}
