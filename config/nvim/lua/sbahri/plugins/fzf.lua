return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  lazy = false,
  keys = {
    -- Files
    { "<leader>ff", "<cmd>FzfLua files<cr>",                      desc = "Find Files" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>",                   desc = "Recent Files" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>",                    desc = "Find Buffers" },

    -- Search
    { "<leader>sg", "<cmd>FzfLua live_grep<cr>",                  desc = "Grep (cwd)" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>",                 desc = "Word (cwd)" },
    { "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>",                 desc = "WORD (cwd)" },
    { "<leader>sg", "<cmd>FzfLua grep_visual<cr>",                mode = "v",                   desc = "Selection (cwd)" },
    { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>",       desc = "Document Symbols" },
    { "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace Symbols" },

    -- LSP
    { "gd",         "<cmd>FzfLua lsp_definitions<cr>",            desc = "Goto Definition" },
    { "gr",         "<cmd>FzfLua lsp_references<cr>",             desc = "References" },
    { "gI",         "<cmd>FzfLua lsp_implementations<cr>",        desc = "Goto Implementation" },
    { "gy",         "<cmd>FzfLua lsp_typedefs<cr>",               desc = "Goto Type Definition" },

    -- Git
    { "<leader>gc", "<cmd>FzfLua git_commits<cr>",                desc = "Commits" },
    { "<leader>gs", "<cmd>FzfLua git_status<cr>",                 desc = "Status" },

    -- Search
    { "<leader>sa", "<cmd>FzfLua<cr>",                            desc = "All Commands" },
    { "<leader>sc", "<cmd>FzfLua commands<cr>",                   desc = "Commands" },
    { "<leader>sh", "<cmd>FzfLua help_tags<cr>",                  desc = "Help Pages" },
    { "<leader>sk", "<cmd>FzfLua keymaps<cr>",                    desc = "Key Maps" },
    { "<leader>sm", "<cmd>FzfLua marks<cr>",                      desc = "Jump to Mark" },
    { "<leader>sR", "<cmd>FzfLua resume<cr>",                     desc = "Resume" },
    { "<leader>sq", "<cmd>FzfLua quickfix<cr>",                   desc = "Quickfix List" },

    -- Misc
    { "<leader>,",  "<cmd>FzfLua buffers<cr>",                    desc = "Switch Buffer" },
    { "<leader>/",  "<cmd>FzfLua live_grep<cr>",                  desc = "Grep (cwd)" },
    { "<leader>:",  "<cmd>FzfLua command_history<cr>",            desc = "Command History" },
  },
  opts = function()
    local actions = require("fzf-lua.actions")

    return {
      "default-title",
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"] = "inline",
      },
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        preview = {
          scrollbar = "float",
          layout = "flex",
          flip_columns = 120,
        },
      },
      files = {
        prompt = "Files❯ ",
        cmd = "fd --type f --hidden --follow --exclude .git",
        actions = {
          ["ctrl-g"] = actions.toggle_ignore,
        },
      },
      grep = {
        prompt = "Rg❯ ",
        input_prompt = "Grep For❯ ",
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        actions = {
          ["ctrl-g"] = actions.toggle_ignore,
        },
      },
      lsp = {
        prompt_postfix = "❯ ",
        symbols = {
          symbol_icons = {
            File = "󰈙",
            Module = "",
            Namespace = "󰦮",
            Package = "",
            Class = "󰆧",
            Method = "󰊕",
            Property = "",
            Field = "",
            Constructor = "",
            Enum = "",
            Interface = "",
            Function = "󰊕",
            Variable = "󰀫",
            Constant = "󰏿",
            String = "",
            Number = "󰎠",
            Boolean = "󰨙",
            Array = "󱡠",
            Object = "",
            Key = "󰌋",
            Null = "󰟢",
            EnumMember = "",
            Struct = "󰆼",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰗴",
          },
        },
      },
      oldfiles = {
        prompt = "History❯ ",
        cwd_only = true,
        include_current_session = true,
      },
    }
  end,
  config = function(_, opts)
    require("fzf-lua").setup(opts)
  end,
}
