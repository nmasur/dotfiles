local M = {}

M.packer = function(use)
    use({
        "akinsho/toggleterm.nvim",
        tag = "v2.1.0",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                direction = "float",
                shell = "fish", -- Force fish for everything
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

            local basicterminal = terminal:new()
            function TERM_TOGGLE()
                basicterminal:toggle()
            end

            local nixpkgs = terminal:new({ cmd = "nix repl '<nixpkgs>'" })
            function NIXPKGS_TOGGLE()
                nixpkgs:toggle()
            end

            local gitwatch = terminal:new({ cmd = "fish --interactive --init-command 'gh run watch'" })
            function GITWATCH_TOGGLE()
                gitwatch:toggle()
            end

            local k9s = terminal:new({ cmd = "k9s" })
            function K9S_TOGGLE()
                k9s:toggle()
            end

            vim.keymap.set("n", "<Leader>t", TERM_TOGGLE)
            vim.keymap.set("n", "<Leader>P", NIXPKGS_TOGGLE)
            vim.keymap.set("n", "<Leader>gw", GITWATCH_TOGGLE)
            vim.keymap.set("n", "<C-k>", K9S_TOGGLE)
        end,
    })

    -- Connect to telescope
    -- use({
    --     "https://git.sr.ht/~havi/telescope-toggleterm.nvim",
    --     event = "TermOpen",
    --     requires = {
    --         "akinsho/nvim-toggleterm.lua",
    --         "nvim-telescope/telescope.nvim",
    --         "nvim-lua/popup.nvim",
    --         "nvim-lua/plenary.nvim",
    --     },
    --     config = function()
    --         require("telescope").load_extension("toggleterm")
    --         require("telescope-toggleterm").setup({
    --             telescope_mappings = {
    --                 -- <ctrl-c> : kill the terminal buffer (default) .
    --                 ["<C-c>"] = require("telescope-toggleterm").actions.exit_terminal,
    --             },
    --         })
    --     end,
    -- })
end

return M
