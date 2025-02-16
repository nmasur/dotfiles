{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.lightdm;
in

{

  options.nmasur.presets.services.lightdm = {
    enable = lib.mkEnableOption "Lightdm display manager";
    wallpaper = {
      type = lib.types.nullOr lib.types.path;
      description = "Wallpaper background image file";
      default = "${pkgs.wallpapers}/gruvbox/road.jpg";
    };
    gtk.theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita-dark";
      };
      package = lib.mkPackageOption pkgs "gnome-themes-extra" { };
    };
  };

  config = lib.mkIf cfg.enable {

    services.xserver = {
      enable = true;

      # Login screen
      displayManager = {
        lightdm = {
          enable = true;
          background = cfg.wallpaper;

          # Show default user
          # Also make sure /var/lib/AccountsService/users/<user> has SystemAccount=false
          extraSeatDefaults = ''
            greeter-hide-users = false
          '';

          # Make the login screen dark
          greeters.gtk.theme = {
            name = cfg.gtk.theme.name;
            package = cfg.gtk.theme.package;
          };

        };
      };
    };
  };
}
