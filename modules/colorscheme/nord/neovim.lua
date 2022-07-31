local M = {}

M.packer = function(use)
    use({
        "shaunsingh/nord.nvim",
        config = function()
            vim.g.nord_italic = true
            vim.cmd("colorscheme nord")
        end,
    })
end

return M
