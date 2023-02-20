-- Set space as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- System clipboard
vim.opt.clipboard = "unnamedplus"

-- Close all windows and exit from Neovim with <leader> and q
vim.keymap.set('n', '<leader>q', ':qa!<CR>')

-- Full colors
vim.opt.termguicolors = true

-- Remove trailing white space
-- https://vi.stackexchange.com/a/37427
vim.api.nvim_create_autocmd({"BufWritePre"}, {
    pattern = {"*"},
    command = [[%s/\s\+$//e]]
})

-- Tabs and spaces
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
