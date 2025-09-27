local Lsp = require("sbahri.lsp")

local ocaml_ft = {
  "dune",
  "ocaml",
  "ocaml.cram",
  "ocaml.interface",
  "ocaml.menhir",
  "ocaml.mlx",
  "ocaml.ocamllex",
  "opam",
  "reason",
}

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
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<leader>cD", vim.lsp.buf.document_symbol, { buffer = bufnr, desc = "Document Symbols" })
          Lsp.on_attach(client, bufnr)
        end,
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
        ocamllsp = false,
      },
    },
  },
}
