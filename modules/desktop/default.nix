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
      enable = mkEnableOption {
        description = "Enable graphics";
        default = false;
      };
      compositor.enable = mkEnableOption {
        description = "Enable transparency, blur, shadows";
        default = false;
      };
      launcherCommand = mkOption {
        type = types.str;
        description = "Command to use for launching";
      };
      gtkTheme = mkOption {
        type = types.str;
        description = "Theme for GTK applications";
      };
      colorscheme = mkOption {
        type = types.attrs;
        description = "Base16 color scheme";
      };
      wallpaper = mkOption {
        type = types.path;
        description = "Wallpaper background image file";
      };
    };

  };

}
