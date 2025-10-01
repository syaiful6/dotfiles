--- Css and HTML language server need to be installed manually
--- it coming from `vscode-langservers-extracted`
---
--- ```sh
--- npm i -g vscode-langservers-extracted
--- ```
local Lsp = require("sbahri.lsp")
local Python = require("sbahri.python")

---@diagnostic disable: missing-fields
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "prospector" },
      },
      linters = {
        ["prospector"] = Python.prospector,
      },
    },
  },
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
}
