{ lib, ... }: {

  imports = [
    ./xorg.nix
    ./fonts.nix
    ./i3.nix
    ./polybar.nix
    ./picom.nix
    # ./dmenu.nix
    ./rofi.nix
  ];

  options = with lib; {

    gui = {
      compositor.enable = mkEnableOption {
        description = "Enable transparency, blur, shadows";
        default = false;
      };
      launcherCommand = mkOption {
        type = types.str;
        description = "Command to use for launching";
      };
      systemdSearch = mkOption {
        type = types.str;
        description = "Command to use for interacting with systemd";
      };
      altTabCommand = mkOption {
        type = types.str;
        description = "Command to use for choosing windows";
      };
      toggleBarCommand = lib.mkOption {
        type = lib.types.str;
        description = "Command to hide and show the status bar.";
      };
      gtk.theme = {
        name = mkOption {
          type = types.str;
          description = "Theme name for GTK applications";
        };
        package = mkOption {
          type = types.str;
          description = "Theme package name for GTK applications";
          default = "gnome-themes-extra";
        };
      };
      wallpaper = mkOption {
        type = types.path;
        description = "Wallpaper background image file";
      };
    };

  };

}
