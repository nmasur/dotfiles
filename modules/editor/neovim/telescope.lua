-- =======================================================================
-- Fuzzy Launcher
-- =======================================================================

use({
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
        -- Telescope: quit instantly with escape
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-h>"] = "which_key",
                    },
                },
            },
            pickers = {
                find_files = { theme = "ivy" },
                oldfiles = { theme = "ivy" },
                buffers = { theme = "dropdown" },
            },
            extensions = {
                fzy_native = {},
                tmux = {},
                zoxide = {},
                --neoclip = {},
                project = {
                    base_dirs = { "~/dev" },
                },
            },
        })
    end,
})

-- Faster sorting
use("nvim-telescope/telescope-fzy-native.nvim")

-- Jump around tmux sessions
use("camgraff/telescope-tmux.nvim")

-- Jump directories
use({
    "jvgrootveld/telescope-zoxide",
    requires = { "nvim-lua/popup.nvim" },
})

-- Jump projects
use({
    "nvim-telescope/telescope-project.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("telescope").load_extension("project")
    end,
})

-- File browser
use({
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("telescope").load_extension("file_browser")
    end,
})
