local Biome = require("sbahri.biome")

local function biome_or(fallback)
  return function(bufnr)
    if Biome.configured(vim.api.nvim_buf_get_name(bufnr)) then
      return { "biome" }
    end
    return { fallback }
  end
end

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
        javascript = biome_or("eslint_d"),
        typescript = biome_or("eslint_d"),
        javascriptreact = biome_or("eslint_d"),
        typescriptreact = biome_or("eslint_d"),
        go = { "gofmt", "goimports" },
        rust = { "rustfmt" },
        ocaml = { "ocamlformat" },
        ["ocaml.mlx"] = { "ocamlxformat" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        html = { "prettier" },
        css = biome_or("prettier"),
        scss = { "prettier" },
        json = biome_or("prettier"),
        jsonc = biome_or("prettier"),
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
        biome = {
          command = function(_, ctx)
            return Biome.command(ctx.filename)
          end,
          cwd = function(_, ctx)
            return Biome.root(ctx.filename)
          end,
          require_cwd = true,
        },
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
