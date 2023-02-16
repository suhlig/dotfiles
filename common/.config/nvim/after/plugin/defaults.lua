-- https://vi.stackexchange.com/a/37427
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})

require('packer').startup(function(use)
  use 'fatih/vim-go'
  use {
      'nvim-tree/nvim-tree.lua',
      requires = { 'nvim-tree/nvim-web-devicons' },
  }
  use({
      "kylechui/nvim-surround",
      tag = "*", -- Use for stability; omit to use `main` branch for the latest features
      config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
      end
  })
end)

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

local o = vim.o

o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2
o.clipboard = "unnamedplus"

-- https://github.com/brainfucksec/neovim-lua
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- NvimTree
keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts) -- open/close
keymap('n', '<leader>f', ':NvimTreeRefresh<CR>', opts) -- refresh
keymap('n', '<leader>n', ':NvimTreeFindFile<CR>', opts) -- search file

-- Reload configuration without restart nvim
keymap('n', '<leader>r', ':so %<CR>', opts)
