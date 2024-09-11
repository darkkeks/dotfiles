-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Enable line numbers and disable wrapping
vim.o.number = true
vim.o.wrap = false

-- Always use 4 spaces for indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.expandtab = true

-- Cursor shape restoration on neovim enter/resume and suspend/exit
vim.api.nvim_create_autocmd({"VimEnter", "VimResume"}, {
  callback = function(ev)
    vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
  end
})
vim.api.nvim_create_autocmd({"VimLeave", "VimSuspend"}, {
  callback = function(ev)
    vim.o.guicursor = 'a:hor25'
  end
})

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
    }
  },
})

-- Default telescope keybinds
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})
