{ pkgs, dsl, ... }:
# with dsl; 
{
  plugins = [
    pkgs.vimPlugins.vim-surround
    pkgs.vimPlugins.vim-eunuch
    pkgs.vimPlugins.vim-vinegar
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.comment-nvim
  ];
  setup.Comment = { };
  lua = ''
    ${builtins.readFile ../lua/keybinds.lua};
    ${builtins.readFile ../lua/settings.lua};
  '';
}
