-- ===========================================================================
-- Custom Functions
-- ===========================================================================

grep_notes = function()
    local opts = {
        prompt_title = "Search Notes",
        cwd = "$NOTES_PATH",
    }
    require("telescope.builtin").live_grep(opts)
end

find_notes = function()
    local opts = {
        prompt_title = "Find Notes",
        cwd = "$NOTES_PATH",
    }
    require("telescope.builtin").find_files(opts)
end

find_downloads = function()
    local opts = {
        prompt_title = "Find Downloads",
        cwd = "~/downloads",
    }
    require("telescope").extensions.file_browser.file_browser(opts)
end

command_history = function()
    local opts = require("telescope.themes").get_ivy({
        layout_config = {
            bottom_pane = {
                height = 15,
            },
        },
    })
    require("telescope.builtin").command_history(opts)
end
