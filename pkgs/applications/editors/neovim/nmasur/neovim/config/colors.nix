{
  pkgs,
  lib,
  config,
  ...
}:
{

  # Sets Neovim colors based on Nix colorscheme

  options.colors = lib.mkOption {
    type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
    description = "Attrset of base16 colorscheme key value pairs.";
    default = {
      # Nord
      base00 = "#2E3440";
      base01 = "#3B4252";
      base02 = "#434C5E";
      base03 = "#4C566A";
      base04 = "#D8DEE9";
      base05 = "#E5E9F0";
      base06 = "#ECEFF4";
      base07 = "#8FBCBB";
      base08 = "#88C0D0";
      base09 = "#81A1C1";
      base0A = "#5E81AC";
      base0B = "#BF616A";
      base0C = "#D08770";
      base0D = "#EBCB8B";
      base0E = "#A3BE8C";
      base0F = "#B48EAD";
    };
  };

  config = lib.mkIf (config.colors != null) {
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
