--- Css and HTML language server need to be installed manually
--- it coming from `vscode-langservers-extracted`
---
--- ```sh
--- npm i -g vscode-langservers-extracted
--- ```
local Lsp = require("sbahri.lsp")

---@diagnostic disable: missing-fields
return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", config = true },
      "mason-org/mason-lspconfig.nvim",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "aznhe21/actions-preview.nvim",
        event = "LspAttach",
        opts = {
          diff = {
            algorithm = "patience",
            ignore_whitespace = true,
          },
        },
      },
      {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
          { "folke/snacks.nvim", opts = { terminal = {} } },
        },
        event = "LspAttach",
        opts = {},
      },
    },
    opts = function(_, opts)
      -- add servers
      local servers = { "cssls", "html", "jsonls", "tsserver", "lua_ls", "bashls", "yamlls" }
      for _, server in ipairs(servers) do
        opts.servers[server] = opts.servers[server] or {}
        opts.servers[server].capabilities = Lsp.capabilities
        opts.servers[server].on_attach = Lsp.on_attach
      end

      vim.g.rustaceanvim = {
        server = vim.tbl_deep_extend("force", {
          capabilities = Lsp.capabilities,
          on_attach = Lsp.on_attach,
        }, opts.servers.rust_analyzer or {}),
      }

      opts.servers["harper-ls"] = vim.tbl_deep_extend("force", {
        cmd = { "harper-ls", "--stdio" },
        root_markers = { ".git" },
        capabilities = Lsp.capabilities,
        on_attach = Lsp.on_attach,
      }, opts.servers["harper-ls"] or {})

      vim.diagnostic.config({ virtual_text = true })

      return opts
    end,
  },
  -- -- Modify `null-ls`
  {
    "nvimtools/none-ls.nvim",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "null-ls" then
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cn", "<cmd>NullLsInfo<cr>", { desc = "NullLs Info" })
          end
        end,
      })
    end,
    opts = function(_, opts)
      local nls = require("null-ls")
      local python = require("sbahri.python")
      nls.register(python.prospector)
      opts.sources = vim.list_extend(opts.sources, {
        nls.builtins.code_actions.gitsigns,
      })
    end,
  },
}
