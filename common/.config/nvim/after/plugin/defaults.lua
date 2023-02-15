-- https://stackoverflow.com/a/72517285
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("v", "\"", ":s/\\%V\\(.*\\)\\%V/\"\\1\"/<CR>", opts)
keymap("v", "\'", ":s/\\%V\\(.*\\)\\%V/\'\\1\'/<CR>", opts)
keymap("v", "(", ":s/\\%V\\(.*\\)\\%V/(\\1)/<CR>", opts)
keymap("v", "[", ":s/\\%V\\(.*\\)\\%V/[\\1]/<CR>", opts)
keymap("v", "{", ":s/\\%V\\(.*\\)\\%V/{\\1}/<CR>", opts)

-- https://vi.stackexchange.com/a/37427
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

require('packer').startup(function(use)
  use 'fatih/vim-go'
end)

local o = vim.o

o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2
o.clipboard = "unnamedplus"
