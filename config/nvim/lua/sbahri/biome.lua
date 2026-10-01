local M = {}

M.config_files = {
  "biome.json",
  "biome.jsonc",
  ".biome.json",
  ".biome.jsonc",
}

---@param path string
---@return string|nil
function M.root(path)
  if path == "" then
    return nil
  end

  local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
  return start and vim.fs.root(start, M.config_files) or nil
end

---@param path string
---@return boolean
function M.configured(path)
  return M.root(path) ~= nil
end

---Find Biome in the nearest ancestor node_modules, falling back to PATH.
---@param path string
---@return string
function M.command(path)
  local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
  if start then
    local node_modules = vim.fs.find("node_modules", {
      path = start,
      upward = true,
      type = "directory",
      limit = math.huge,
    })

    for _, directory in ipairs(node_modules) do
      local command = vim.fs.joinpath(directory, ".bin", "biome")
      if vim.fn.executable(command) == 1 then
        return command
      end
    end
  end

  return "biome"
end

return M
