return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    opts = {
      ensure_installed = {
        "bash",
        "regex",
        "vim",
        "lua",
        "html",
        "markdown",
        "markdown_inline",
        "css",
        "typescript",
        "tsx",
        "javascript",
        "json",
        "graphql",
        "prisma",
        "rust",
        "go",
        "toml",
        "c",
        "proto",
        "ocaml",
        "ocaml_interface",
        "scss",
        "swift",
        "nix",
        "starlark",
      },
      highlight = {
        enable = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local parsers = require("nvim-treesitter.parsers").get_parser_configs()
      parsers.reason = {
        install_info = {
          url = "https://github.com/reasonml-editor/tree-sitter-reason",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "master",
        },
      }
      parsers.koka = {
        install_info = {
          url = "https://github.com/mtoohey31/tree-sitter-koka",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
      }
    end,
  },
}
