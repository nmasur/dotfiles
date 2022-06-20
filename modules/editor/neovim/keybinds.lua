-- ===========================================================================
-- Key Mapping
-- ===========================================================================

-- Function to cut down config boilerplate
local key = function(mode, key_sequence, action, params)
    params = params or {}
    params["noremap"] = true
    vim.api.nvim_set_keymap(mode, key_sequence, action, params)
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
key("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
key("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
key("v", "<A-j>", ":m '>+1<CR>gv=gv")
key("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Telescope (fuzzy finder)
key("n", "<Leader>k", ":Telescope keymaps<CR>")
key("n", "<Leader>/", ":Telescope live_grep<CR>")
key("n", "<Leader>ff", ":Telescope find_files<CR>")
key("n", "<Leader>fp", ":Telescope git_files<CR>")
key("n", "<Leader>fN", "<Cmd>lua find_notes()<CR>")
key("n", "<Leader>N", "<Cmd>lua grep_notes()<CR>")
key("n", "<Leader>fD", "<Cmd>lua find_downloads()<CR>")
key("n", "<Leader>fa", ":Telescope file_browser<CR>")
key("n", "<Leader>fw", ":Telescope grep_string<CR>")
key("n", "<Leader>wt", ":Telescope tmux sessions<CR>")
key("n", "<Leader>ww", ":Telescope tmux windows<CR>")
key("n", "<Leader>w/", ":Telescope tmux pane_contents<CR>")
key("n", "<Leader>fz", ":Telescope zoxide list<CR>")
key("n", "<Leader>b", ":Telescope buffers<CR>")
key("n", "<Leader>hh", ":Telescope help_tags<CR>")
key("n", "<Leader>fr", ":Telescope oldfiles<CR>")
key("n", "<Leader>cc", ":Telescope commands<CR>")
key("n", "<Leader>cr", "<Cmd>lua command_history()<CR>")
key("n", "<Leader>y", "<Cmd>lua clipboard_history()<CR>")
key("i", "<c-y>", "<Cmd>lua clipboard_history()<CR>")
key("n", "<Leader>s", ":Telescope current_buffer_fuzzy_find<CR>")
key("n", "<Leader>gc", ":Telescope git_commits<CR>")
key("n", "<Leader>gf", ":Telescope git_bcommits<CR>")
key("n", "<Leader>gb", ":Telescope git_branches<CR>")
key("n", "<Leader>gs", ":Telescope git_status<CR>")
key("n", "<C-p>", "<Cmd>lua choose_project()<CR>")

-- Buffer tabs (tmux interferes)
-- key("n", "<C-L>", "gt")
-- key("i", "<C-L>", "<Esc>gt")
-- key("n", "<C-H>", "gT")
-- key("i", "<C-H>", "<Esc>gT")

-- LSP
key("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
key("n", "gT", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", { silent = true })
key("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", { silent = true })
key("n", "gh", "<Cmd>lua vim.lsp.buf.hover()<CR>", { silent = true })
key("n", "gr", "<Cmd>Telescope lsp_references<CR>", { silent = true })
key("n", "<Leader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>", { silent = true })
key("n", "]e", "<Cmd>lua vim.diagnostic.goto_next()<CR>", { silent = true })
key("n", "[e", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", { silent = true })
key("n", "<Leader>e", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", { silent = true })
key("n", "<Leader>E", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { silent = true })

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

-- Other
key("t", "<A-CR>", "<C-\\><C-n>") --- Exit terminal mode
key("n", "<A-CR>", ":noh<CR>", { silent = true }) --- Clear search in VimWiki
key("n", "Y", "y$") --- Copy to end of line
key("v", "<C-r>", "y<Esc>:%s/<C-r>+//gc<left><left><left>") --- Substitute selected
key("v", "D", "y'>gp") --- Duplicate selected
