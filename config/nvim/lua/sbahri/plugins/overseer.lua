return {
  {
    "stevearc/overseer.nvim",
    version = "*",
    keys = {
      { "<leader>or", "<cmd>OverseerRun<cr>",        desc = "Run a task from a template" },
      { "<leader>ot", "<cmd>OverseerToggle<cr>",     desc = "Toggle the overseer window" },
      { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Select a task to run an action on" },
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
      templates = { "builtin", "ocaml.dune" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, { "overseer" })
    end,
  },
}
