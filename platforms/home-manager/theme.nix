{ lib, ... }:

{

  options.theme = {
    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Color palette name (fallback when individual colors aren't specified)";
      default = "gruvbox";
    };
    colors = lib.mkOption {
      type = lib.types.attrs;
      description = "Base16 color scheme.";
      default = (import ../colorscheme/gruvbox).dark;
    };
    mode = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      description = "Light or dark mode";
      default = "dark";
    };
  };

}
