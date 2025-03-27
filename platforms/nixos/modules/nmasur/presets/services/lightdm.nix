{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.lightdm;
in

{

  options.nmasur.presets.services.lightdm = {
    enable = lib.mkEnableOption "Lightdm display manager";
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Wallpaper background image file";
      default = "${pkgs.nmasur.wallpapers}/gruvbox/road.jpg";
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

    programs.fish.enable = lib.mkIf (config.home-manager.users.${username}.programs.fish.enable) true; # Needed for LightDM to remember username

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
