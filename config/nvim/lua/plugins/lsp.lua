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
    event = "LazyFile",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        fish = { "fish" },
        python = { "prospector" },
        markdown = { "markdownlint" },
        typescript = { "eslint" },
        javascript = { "eslint" },
        typescriptreact = { "eslint" },
        javascriptreact = { "eslint" },
        lua = { "luacheck" },
      },
      linters = {
        ["prospector"] = Python.prospector,
      },
    },
    config = function(_, opts)
      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          -- evaluate linter if it's a function, the check if it has a condition field
          if type(linter) == "function" then
            linter = linter()
          end
          --- this is probably better in nvim-lint itself, let's check the command line is
          --- actually available
          local cmd = linter and (type(linter.cmd) == "function" and linter.cmd() or linter.cmd)
          if vim.fn.executable(cmd or "") ~= 1 then
            return false
          end
          --- normal check, LazyVim support condition field
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
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
