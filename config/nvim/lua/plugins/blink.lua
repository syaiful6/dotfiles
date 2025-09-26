return {
  { "giuxtaposition/blink-cmp-copilot" },
  {
    "saghen/blink.cmp",
    dependencies = {
      { "giuxtaposition/blink-cmp-copilot" },
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
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
    specs = {
      {
        "zbirenbaum/copilot.lua",
        optional = true,
        specs = {
          {
            "saghen/blink.cmp",
            optional = true,
            opts = function(_, opts)
              opts.sources = opts.sources or {}
              opts.sources.default = opts.sources.default or {}
              opts.sources.providers = opts.sources.providers or {}

              -- Add copilot to default sources if copilot is available
              if LazyVim.has("copilot.lua") then
                table.insert(opts.sources.default, "copilot")
              end

              -- Configure copilot provider
              opts.sources.providers.copilot = {
                name = "copilot",
                module = "blink-cmp-copilot",
                score_offset = 100,
                async = true,
              }
            end,
          },
        },
      },
    },
  },
}
