{ pkgs, ... }:
{
  plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
  setup.gitsigns = { };
  lua = builtins.readFile ./gitsigns.lua;
}
