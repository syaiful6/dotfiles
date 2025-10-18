local constants = require("overseer.constants")
local overseer = require("overseer")
local TAG = constants.TAG

---@type overseer.TemplateFileDefinition
local tmpl = {
  priority = 60,
  params = {
    args = { type = "list", delimiter = " " },
    cwd = { optional = true },
    relative_file_root = {
      desc = "Relative filepath will be joined to this root (instead of task cwd)",
      optional = true,
    },
  },
  builder = function(params)
    local sandbox = require("ocaml.sandbox")
    return {
      cmd = sandbox.get_command(params.relative_file_root or params.cwd, { "dune" }),
      args = params.args,
      cwd = params.cwd,
      default_component_params = {
        relative_file_root = params.relative_file_root,
      },
    }
  end,
}

---@param opts overseer.SearchParams
---@return nil|string
local function find_dune_project_file(opts)
  local root_pattern = require("ocaml.helpers").root_pattern("dune-project", "dune-workspace")
  return root_pattern(opts.dir)
end

---@param opts overseer.SearchParams
---@return nil|string
local function find_dune_file(opts)
  return vim.fs.find("dune", { upward = true, type = "file", path = opts.dir })[1]
end

return {
  cache_key = function(opts)
    return find_dune_file(opts)
  end,
  condition = {
    callback = function(opts)
      if not find_dune_project_file(opts) then
        return false, "No dune-project file found"
      end
      --- we need to check dune is installed, but it usually hidden in the sandbox
      --- for now we just assume it is installed if dune-project file is found
      return true
    end,
  },
  generator = function(opts, cb)
    local project_dir = find_dune_project_file(opts)
    local dune_file = find_dune_file(opts)
    local lib_dir = dune_file and vim.fs.dirname(dune_file) or project_dir
    local ret = {}

    local commands = {
      { args = { "build" }, tags = { TAG.BUILD } },
      { args = { "build", "--watch" }, tags = { TAG.BUILD } },
      { args = { "clean" }, tags = { TAG.CLEAN } },
      { args = { "test" }, tags = { TAG.TEST } },
      { args = { "fmt" } },
    }

    local roots = { {
      postfix = "",
      cwd = lib_dir,
      priority = 60,
    } }
    if project_dir ~= lib_dir then
      roots[1].relative_file_root = project_dir
      table.insert(roots, {
        postfix = " (workspace)",
        cwd = project_dir,
        priority = 50,
      })
    end
    for _, root in ipairs(roots) do
      for _, cmd in ipairs(commands) do
        table.insert(
          ret,
          overseer.wrap_template(tmpl, {
            name = string.format("dune %s%s", table.concat(cmd.args, " "), root.postfix),
            tags = cmd.tags,
            priority = root.priority,
          }, { args = cmd.args, cwd = root.cwd, relative_file_root = root.relative_file_root })
        )
      end
      -- allow user to add cmd and args
      table.insert(
        ret,
        overseer.wrap_template(
          tmpl,
          { name = "dune" .. root.postfix },
          { cwd = root.cwd, relative_file_root = root.relative_file_root }
        )
      )
    end
    -- We are completely synchronous, it will be interesting if we can search
    -- all dune files asynchronously relative to project_dir
    cb(ret)
  end,
}
