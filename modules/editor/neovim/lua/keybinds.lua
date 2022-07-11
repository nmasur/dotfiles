-- ===========================================================================
-- Key Mapping
-- ===========================================================================

-- Function to cut down config boilerplate
local key = function(mode, key_sequence, action, params)
    params = params or {}
    vim.keymap.set(mode, key_sequence, action, params)
end

-- Remap space as leader key
key("", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keep selection when changing indentation
key("v", "<", "<gv")
key("v", ">", ">gv")

-- Clear search register
key("n", "<CR>", ":noh<CR><CR>", { silent = true })

-- Shuffle lines around
key("n", "<A-j>", ":m .+1<CR>==")
key("n", "<A-k>", ":m .-2<CR>==")
-- key("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
-- key("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
key("v", "<A-j>", ":m '>+1<CR>gv=gv")
key("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Telescope (fuzzy finder)
local telescope = require("telescope.builtin")
local telescope_ext = require("telescope").extensions
key("n", "<Leader>k", telescope.keymaps)
key("n", "<Leader>/", telescope.live_grep)
key("n", "<Leader>ff", telescope.find_files)
key("n", "<Leader>fp", telescope.git_files)
key("n", "<Leader>fN", find_notes)
key("n", "<Leader>N", grep_notes)
key("n", "<Leader>fD", find_downloads)
key("n", "<Leader>fa", telescope_ext.file_browser.file_browser)
key("n", "<Leader>fw", telescope.grep_string)
-- key("n", "<Leader>wt", ":Telescope tmux sessions<CR>")
-- key("n", "<Leader>ww", ":Telescope tmux windows<CR>")
-- key("n", "<Leader>w/", ":Telescope tmux pane_contents<CR>")
key("n", "<Leader>fz", telescope_ext.zoxide.list)
key("n", "<Leader>b", telescope.buffers)
key("n", "<Leader>hh", telescope.help_tags)
key("n", "<Leader>fr", telescope.oldfiles)
key("n", "<Leader>cc", telescope.commands)
key("n", "<Leader>cr", command_history)
key("n", "<Leader>s", telescope.current_buffer_fuzzy_find)
key("n", "<Leader>gc", telescope.git_commits)
key("n", "<Leader>gf", telescope.git_bcommits)
key("n", "<Leader>gb", telescope.git_branches)
key("n", "<Leader>gs", telescope.git_status)

-- Buffer tabs (tmux interferes)
-- key("n", "<C-L>", "gt")
-- key("i", "<C-L>", "<Esc>gt")
-- key("n", "<C-H>", "gT")
-- key("i", "<C-H>", "<Esc>gT")

-- Swap buffers
key("n", "L", ":bnext<CR>")
key("n", "H", ":bprevious<CR>")

-- LSP
key("n", "gd", vim.lsp.buf.definition, { silent = true })
key("n", "gT", vim.lsp.buf.type_definition, { silent = true })
key("n", "gi", vim.lsp.buf.implementation, { silent = true })
key("n", "gh", vim.lsp.buf.hover, { silent = true })
key("n", "gr", telescope.lsp_references, { silent = true })
key("n", "<Leader>R", vim.lsp.buf.rename, { silent = true })
key("n", "]e", vim.diagnostic.goto_next, { silent = true })
key("n", "[e", vim.diagnostic.goto_prev, { silent = true })
key("n", "<Leader>e", vim.diagnostic.open_float, { silent = true })
key("n", "<Leader>E", vim.lsp.buf.code_action, { silent = true })

-- File commands
key("n", "<Leader>q", ":quit<CR>")
key("n", "<Leader>Q", ":quitall<CR>")
key("n", "<Leader>fs", ":write<CR>")
key("n", "<Leader>fd", ":lcd %:p:h<CR>", { silent = true })
key("n", "<Leader>fu", ":lcd ..<CR>", { silent = true })
key("n", "<Leader><Tab>", ":b#<CR>", { silent = true })
key("n", "<Leader>gr", ":!gh repo view -w<CR><CR>", { silent = true })
key("n", "<Leader>tt", [[<Cmd>exe 'edit $NOTES_PATH/journal/'.strftime("%Y-%m-%d_%a").'.md'<CR>]])
key("n", "<Leader>jj", ":!journal<CR>:e<CR>")

-- Window commands
key("n", "<Leader>wv", ":vsplit<CR>")
key("n", "<Leader>wh", ":split<CR>")
key("n", "<Leader>wm", ":only<CR>")

-- Tabularize
key("", "<Leader>ta", ":Tabularize /")
key("", "<Leader>t#", ":Tabularize /#<CR>")
key("", "<Leader>tl", ":Tabularize /---<CR>")

-- Vimrc editing
key("n", "<Leader>fv", ":edit $DOTS/nvim.configlink/init.lua<CR>")
key("n", "<Leader>rr", ":luafile $MYVIMRC<CR>")
key("n", "<Leader>rp", ":luafile $MYVIMRC<CR>:PackerInstall<CR>:")
key("n", "<Leader>rc", ":luafile $MYVIMRC<CR>:PackerCompile<CR>")

-- Keep cursor in place
key("n", "n", "nzz")
key("n", "N", "Nzz")
key("n", "J", "mzJ`z") --- Mark and jump back to it

-- Add undo breakpoints
key("i", ",", ",<C-g>u")
key("i", ".", ".<C-g>u")
key("i", "!", "!<C-g>u")
key("i", "?", "?<C-g>u")

-- Resize with arrows
key("n", "<C-Up>", ":resize +2<CR>", { silent = true })
key("n", "<C-Down>", ":resize -2<CR>", { silent = true })
key("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
key("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- Other
key("t", "<A-CR>", "<C-\\><C-n>") --- Exit terminal mode
key("n", "<A-CR>", ":noh<CR>", { silent = true }) --- Clear search in VimWiki
key("n", "Y", "y$") --- Copy to end of line
key("v", "<C-r>", "y<Esc>:%s/<C-r>+//gc<left><left><left>") --- Substitute selected
key("v", "D", "y'>gp") --- Duplicate selected
