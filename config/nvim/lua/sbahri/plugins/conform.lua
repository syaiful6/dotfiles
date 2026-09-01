return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
    keys = {
      {
        "<leader>cf",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          require("conform").format({
            async = true,
            lsp_fallback = #require("conform").list_formatters(bufnr) == 0,
          })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        go = { "gofmt", "goimports" },
        rust = { "rustfmt" },
        ocaml = { "ocamlformat" },
        ["ocaml.mlx"] = { "ocamlxformat" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        php = { "php_cs_fixer" },
        haskell = { "fourmolu" },
        cabal = { "cabal_fmt" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 500,
          lsp_fallback = #require("conform").list_formatters(bufnr) == 0,
        }
      end,
      formatters = {
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        ocamlxformat = {
          meta = {
            url = "https://github.com/ocaml-mlx/ocamlformat-mlx",
            description = "OCaml code formatter",
          },
          command = "ocamlformat-mlx",
          args = { "--enable-outside-detected-project", "--impl", "--name", "$FILENAME", "-" },
        },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
      -- Format on save toggle commands
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! disables globally
          vim.g.disable_autoformat = true
        else
          -- FormatDisable disables for current buffer
          vim.b.disable_autoformat = true
        end
      end, {
        desc = "Disable format on save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Enable format on save",
      })
    end,
  },
}
