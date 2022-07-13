local M = {}

M.packer = function(use)
    use({
        "akinsho/toggleterm.nvim",
        tag = "v2.*",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                direction = "float",
            })

            vim.keymap.set("t", "<A-CR>", "<C-\\><C-n>") --- Exit terminal mode

            -- Only set these keymaps for toggleterm
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "term://*toggleterm#*",
                callback = function()
                    -- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>") --- Exit terminal mode
                    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
                    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
                    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
                    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
                end,
            })

            local terminal = require("toggleterm.terminal").Terminal
            local nixpkgs = terminal:new({ cmd = "nix repl '<nixpkgs>'" })
            function NIXPKGS_TOGGLE()
                nixpkgs:toggle()
            end
        end,
    })
end

return M
