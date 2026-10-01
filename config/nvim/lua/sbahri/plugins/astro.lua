local PARSERS = {
  astro = {
    install_info = {
      url = "https://github.com/virchau13/tree-sitter-astro",
      files = { "src/parser.c", "src/scanner.c" },
      branch = "master",
    },
    filetype = "astro",
  },
}

---Get parser configurations
---@return table parser_configs
local function get_parser_config()
  if not pcall(require, "nvim-treesitter") then
    return {}
  end

  local parsers = require("nvim-treesitter.parsers")
  return parsers.get_parser_configs and parsers.get_parser_configs() or parsers
end

local function register_parsers(parsers_config)
  for name, info in pairs(PARSERS) do
    parsers_config[name] = info
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local parsers_config = get_parser_config()
      register_parsers(parsers_config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local config = get_parser_config()
          register_parsers(config)
        end,
      })

      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "astro" })
    end,
  },
}
