--- Css and HTML language server need to be installed manually
--- it coming from `vscode-langservers-extracted`
---
--- ```sh
--- npm i -g vscode-langservers-extracted
--- ```

---@diagnostic disable: missing-fields
return {
  -- Customize LSP
  {
    "neovim/nvim-lspconfig",
    -- Add, change or remove keymaps
    init = function()
      -- disable lsp watcher. Too slow on linux
      local ok, wf = pcall(require, "vim.lsp._watchfiles")
      if ok then
        wf._watchfunc = function()
          return function() end
        end
      end
    end,
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "icons",
          spacing = 4,
          source = "if_many",
        },
        -- virtual_text = false,
      },
      inlay_hints = {
        -- enabled = true,
      },
      servers = {
        yamlls = {},
        css = {
          cmd = { "vscode-css-language-server", "--stdio" },
          filetypes = { "css", "scss", "less" },
          root_markers = { "package.json", ".git" },
        },
        html = {
          cmd = { "vscode-html-language-server", "--stdio" },
          filetypes = { "html", "django-html", "htmldjango", "templ" },
        },
        tsserver = {
          -- Need to disable this cuz `Inline Edit` won't work otherwise
          -- single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                -- disable = { "missing-parameter" },
              },
              hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "All",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      setup = {
        css = function()
          if vim.lsp.config.css then
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            vim.lsp.config("css", {
              capabilities = capabilities,
            })
          end
        end,
        html = function()
          if vim.lsp.config.html then
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            vim.lsp.config("html", {
              capabilities = capabilities,
            })
          end
        end,
      },
    },
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        lazy = true,
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
        opts = { lsp = { auto_attach = true } },
        keys = {
          { "<leader>cln", "<cmd>Navbuddy<cr>", desc = "Lsp Navigation" },
        },
      },

      {
        "simrat39/symbols-outline.nvim",
        lazy = true,
        keys = {
          { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
        },
        opts = {
          width = 35,
          autofold_depth = 2,
        },
      },

      -- Pretty hover
      {
        "Fildo7525/pretty_hover",
        event = "LspAttach",
        opts = {},
      },
    },
  },

  -- Modify `null-ls`
  {
    "nvimtools/none-ls.nvim",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.name == "null-ls" then
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cn", "<cmd>NullLsInfo<cr>", { desc = "NullLs Info" })
          end
        end,
      })
    end,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources, {
        nls.builtins.code_actions.gitsigns,
      })
    end,
  },
}
