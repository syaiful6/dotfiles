-- Load core configurations first
require("sbahri.options")
require("sbahri.keymaps")
require("sbahri.ui2").setup()

-- Add file type
vim.filetype.add({
  extension = {
    nomad = 'hcl',
  }
})
-- html/template filetype: templates/*.html is Django by default, but a
-- Go project (go.mod present, no manage.py) using the same convention
-- should be treated as a Go template instead.
vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
    tmpl = 'gotmpl',
  },
  pattern = {
    ['.*/templates/.*%.html'] = function(path)
      if vim.fs.root(path, 'manage.py') then
        return 'htmldjango'
      end
      if vim.fs.root(path, 'go.mod') then
        return 'gotmpl'
      end
      return 'htmldjango'
    end,
    -- Hugo's default template directory; unambiguously Go templates.
    ['.*/layouts/.*%.html'] = 'gotmpl',
  }
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugins
require("lazy").setup({
  { import = "sbahri.plugins" },
}, {
  change_detection = {
    notify = false,
  },
  dev = {
    path = "~/Developer/prj/nvim",
    fallback = true, -- fallback since on other devices I may not have my local plugins
  },
  performance = {
    rtp = {
      -- Disable some rtp plugins for performance
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
