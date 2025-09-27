local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local utils = require("null-ls.utils")

local M = {}

---@param command string The command to find in the virtual environment or system PATH
---@return string|nil The full path to the command if found, otherwise nil
function M.get_env_tool(command)
  local venv_python = os.getenv("VIRTUAL_ENV")
  if venv_python then
    local venv_cmd = venv_python .. "/bin/" .. command
    if vim.fn.executable(venv_cmd) == 1 then
      return venv_cmd
    end
  end

  local project_venv = vim.fn.getcwd() .. "/.venv/bin/" .. command
  if vim.fn.executable(project_venv) == 1 then
    return project_venv
  end

  if vim.fn.executable(command) == 1 then
    return command
  end

  return nil
end

--- prospector diagnostics generator to be used with null-ls
M.prospector = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_ls.generator({
    command = function()
      return M.get_env_tool("prospector") or "prospector"
    end,
    args = { "-F", "--output-format", "json", "$FILENAME" },
    env = { "PYTHONWARNING=ignore" },
    format = "json",
    check_exit_code = function(code)
      return code ~= 32
    end,
    on_output = function(params)
      local diagnostics = {}
      local messages = params.output.messages or {}
      for _, json_diag in ipairs(messages) do
        local location = json_diag.location or {}
        local entries = {
          source = json_diag.source or "prospector",
          code = json_diag.code,
          severity = 2, -- not sure, prospector doesn't provide severity
          message = json_diag.message,
          row = location.line or 1,
          col = location.character or 1,
        }
        table.insert(diagnostics, entries)
      end

      return diagnostics
    end,
    cwd = helpers.cache.by_bufnr(function(params)
      return utils.root_pattern(
        "manage.py", -- django use manage.py as root
        "prospector.yaml",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json"
      )(params.bufname)
    end),
  }),
}

return M
