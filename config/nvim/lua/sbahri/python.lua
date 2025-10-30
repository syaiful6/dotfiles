local Helpers = require("sbahri.helpers")

local M = {}

---@param command string The command to find in the virtual environment or system PATH
---@return string|nil The full path to the command if found, otherwise nil
function M.get_venv_tool(command)
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

local prospector_root_dir = Helpers.root_pattern(
  "manage.py", -- django use manage.py as root
  "prospector.yaml",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "pyrightconfig.json"
)

local prospector_parser = function(output)
  if output == nil or output == "" then
    return {}
  end
  local diagnostics = {}
  local ok, decoded = pcall(vim.fn.json_decode, output)
  if not ok then
    return {}
  end
  for _, json_diag in ipairs(decoded.messages or {}) do
    local location = json_diag.location or {}
    local line = location.line ~= vim.NIL and (location.line - 1) or 1
    local column = location.character ~= vim.NIL and location.character or 1
    local entries = {
      source = json_diag.source or "prospector",
      code = json_diag.code,
      severity = vim.diagnostic.severity.WARN, -- not sure, prospector doesn't provide severity
      message = json_diag.message,
      lnum = line,
      col = column,
      end_lnum = line,
      end_col = column,
    }
    table.insert(diagnostics, entries)
  end
  return diagnostics
end

M.prospector = function()
  local fname = vim.api.nvim_buf_get_name(0)
  local path = prospector_root_dir(fname)
  local envs = { PYTHONWARNING = "ignore", ["DJANGO_SETTINGS_MODULE"] = "settings" }
  local current_python_path = vim.fn.getenv("PYTHONPATH")
  -- Convert userdata to string if needed
  current_python_path = current_python_path and tostring(current_python_path) or ""
  if current_python_path ~= "" then
    envs["PYTHONPATH"] = path .. ":" .. current_python_path
  else
    envs["PYTHONPATH"] = path
  end

  return {
    cmd = M.get_venv_tool("prospector") or "prospector",
    args = {
      "-F",
      "--output-format",
      "json",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    },
    cwd = path,
    env = envs,
    stdin = false,
    stream = "stdout",
    ignore_exitcode = true,
    parser = prospector_parser,
    condition = function()
      local cmd = M.get_venv_tool("prospector") or "prospector"
      return vim.fn.executable(cmd) == 1
    end,
  }
end

return M
