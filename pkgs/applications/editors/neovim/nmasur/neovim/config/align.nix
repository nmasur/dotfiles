{ pkgs, ... }:
{

  # Plugin for aligning text programmatically

  plugins = [ pkgs.vimPlugins.tabular ];
  lua = ''
    -- Align
    vim.keymap.set("", "<Leader>ta", ":Tabularize /")
    vim.keymap.set("", "<Leader>t#", ":Tabularize /#<CR>")
    vim.keymap.set("", "<Leader>tl", ":Tabularize /---<CR>")
  '';
}
