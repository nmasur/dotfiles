{ pkgs, ... }: {

  plugins = [ pkgs.vimPlugins.vim-gruvbox8 ];

  vim.g.gruvbox_italicize_strings = 0;
  vim.o.background = "dark";
  vimscript = ''
    let g:gruvbox_italicize_strings = 0
    colorscheme gruvbox8
  '';

}
