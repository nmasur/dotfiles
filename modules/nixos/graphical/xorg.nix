{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf config.gui.enable {

    # Enable touchpad support
    services.libinput.enable = true;

    # Enable the X11 windowing system.
    services.xserver = {
      enable = config.gui.enable;

      # Login screen
      displayManager = {
        lightdm = {
          enable = config.services.xserver.enable;
          background = config.wallpaper;

          # Show default user
          # Also make sure /var/lib/AccountsService/users/<user> has SystemAccount=false
          extraSeatDefaults = ''
            greeter-hide-users = false
          '';
        };
      };
    };

    environment.systemPackages = with pkgs; [
      xclip # Clipboard
    ];

    home-manager.users.${config.user} = {

      programs.fish.shellAliases = {
        pbcopy = "xclip -selection clipboard -in";
        pbpaste = "xclip -selection clipboard -out";
      };
    };
  };
}
