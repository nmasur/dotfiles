{
  pkgs,
  lib,
  config,
  ...
}:
{

  # Sets Neovim colors based on Nix colorscheme

  options.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    description = "Attrset of base16 colorscheme key value pairs.";
  };

  config = {
    plugins = [ pkgs.vimPlugins.base16-nvim ];
    setup.base16-colorscheme = config.colors;

    # Telescope isn't working, shut off for now
    lua = ''
      require('base16-colorscheme').with_config {
          telescope = false,
      }
    '';
  };
}
