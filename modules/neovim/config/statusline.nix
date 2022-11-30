{ pkgs, ... }: {
  plugins = [ pkgs.vimPlugins.lualine-nvim ];
  setup.lualine = {
    options = {
      theme = "gruvbox";
      icons_enabled = true;
    };
  };
}
