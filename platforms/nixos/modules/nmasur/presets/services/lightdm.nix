{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.lightdm;
in

{

  options.nmasur.presets.services.lightdm.enable = lib.mkEnableOption "Lightdm display manager";

  config = lib.mkIf cfg.enable {

    services.xserver = {
      enable = true;

      # Login screen
      displayManager = {
        lightdm = {
          enable = true;
          background = config.wallpaper;

          # Show default user
          # Also make sure /var/lib/AccountsService/users/<user> has SystemAccount=false
          extraSeatDefaults = ''
            greeter-hide-users = false
          '';
        };
      };
    };
  };
}
