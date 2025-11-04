-- Load core configurations first
require("sbahri.options")
require("sbahri.keymaps")

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
