-- Set leader to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set colorscheme
vim.cmd.colorscheme 'wombat256mod'

-- Enable line numbers
vim.opt.number = true;

-- Disable mouse
vim.opt.mouse = ''

-- Tabs
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- Linters
vim.api.nvim_create_autocmd({ "TextChanged" }, {
  callback = function()
    require("lint").try_lint()
  end,
})


-- Formatters
vim.api.nvim_create_augroup("__formatter__", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

-- Load Lazy (package manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
  "plugins"
)
