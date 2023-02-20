return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    config = function()
        -- Unless you are still migrating, remove the deprecated commands from v1.x
        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        require('neo-tree').setup({
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_hidden = false,
                    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                        -- ".DS_Store",
                        -- "thumbs.db"
                    },
                }
            }
        })
        vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>')
    end
}
