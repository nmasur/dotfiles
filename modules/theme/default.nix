{ config, lib, gui, ... }:

let

  themes = {
    "carbonfiber" = ./carbonfiber;
    "gruvbox" = ./gruvbox;
    "nord" = ./nord;
  };

in {

  options.theme = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Name of the theme";
    };
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Set of colors";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ./.;
      description = "Path to wallpaper image";
    };
    opacity = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Opacity of certain windows";
    };
  };

  config.theme = (import themes.${gui.theme});

}
