return {
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        version = "v2.*",
        config = function()
          local luasnip = require("luasnip")
          -- require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })

          luasnip.config.set_config({
            region_check_events = "InsertEnter",
            delete_check_events = "InsertLeave",
          })

          luasnip.config.setup({})
        end,
      },
    },
    opts = {
      snippets = { preset = "luasnip" },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      keymap = {
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          function()
            return require("sidekick").nes_jump_or_apply()
          end,
          "fallback",
        },
      },
    },
  },
}
