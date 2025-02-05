local telescope = require("telescope.builtin")
vim.keymap.set("n", "<Leader>k", telescope.keymaps)
vim.keymap.set("n", "<Leader>/", telescope.live_grep)
vim.keymap.set("n", "<Leader>ff", telescope.find_files)
vim.keymap.set("n", "<Leader>fp", telescope.git_files)
vim.keymap.set("n", "<Leader>fw", telescope.grep_string)
vim.keymap.set("n", "<Leader>b", telescope.buffers)
vim.keymap.set("n", "<Leader>hh", telescope.help_tags)
vim.keymap.set("n", "<Leader>fr", telescope.oldfiles)
vim.keymap.set("n", "<Leader>cc", telescope.commands)
vim.keymap.set("n", "<Leader>gc", telescope.git_commits)
vim.keymap.set("n", "<Leader>gf", telescope.git_bcommits)
vim.keymap.set("n", "<Leader>gb", telescope.git_branches)
vim.keymap.set("n", "<Leader>gs", telescope.git_status)
vim.keymap.set("n", "<Leader>s", telescope.current_buffer_fuzzy_find)
vim.keymap.set("n", "<Leader>rr", telescope.resume)

vim.keymap.set("n", "<Leader>N", function()
    local opts = {
        prompt_title = "Search Notes",
        cwd = "$NOTES_PATH",
    }
    telescope.live_grep(opts)
end)

vim.keymap.set("n", "<Leader>fN", function()
    local opts = {
        prompt_title = "Find Notes",
        cwd = "$NOTES_PATH",
    }
    telescope.find_files(opts)
end)

vim.keymap.set("n", "<Leader>cr", function()
    local opts = require("telescope.themes").get_ivy({
        layout_config = {
            bottom_pane = {
                height = 15,
            },
        },
    })
    telescope.command_history(opts)
end)

-- Zoxide
vim.keymap.set("n", "<Leader>fz", require("telescope").extensions.zoxide.list)

-- Project
require("telescope").load_extension("projects")
vim.keymap.set("n", "<C-p>", function()
    local opts = require("telescope.themes").get_ivy({
        layout_config = {
            bottom_pane = {
                height = 10,
            },
        },
    })
    require("telescope").extensions.projects.projects(opts)
end)

-- File browser
require("telescope").load_extension("file_browser")
vim.keymap.set("n", "<Leader>fa", require("telescope").extensions.file_browser.file_browser)
vim.keymap.set("n", "<Leader>fD", function()
    local opts = {
        prompt_title = "Find Downloads",
        cwd = "~/downloads",
    }
    require("telescope").extensions.file_browser.file_browser(opts)
end)
