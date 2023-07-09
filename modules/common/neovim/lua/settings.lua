-- ===========================================================================
-- Settings
-- ===========================================================================

vim.filetype.add({
    pattern = {
        [".*%.tfvars"] = "terraform",
        [".*%.tf"] = "terraform",
        [".*%.rasi"] = "rasi",
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*.eml",
    callback = function()
        vim.o.wrapmargin = 79 -- Wrap text automatically
    end,
})
