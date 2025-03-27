{ pkgs, ... }:
{
  plugins = [ pkgs.vimPlugins.lualine-nvim ];
  setup.lualine = {
    options = {
      theme = "base16";
      icons_enabled = true;
    };
  };
}
