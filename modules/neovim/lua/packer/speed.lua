local M = {}

M.packer = function(use)
    -- Startup speed hacks
    use({
        "lewis6991/impatient.nvim",
        config = function()
            require("impatient")
        end,
    })
end

return M
