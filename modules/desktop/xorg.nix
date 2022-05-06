{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {

    # Enable the X11 windowing system.
    services.xserver = {
      enable = config.gui.enable;

      # Enable touchpad support
      libinput.enable = true;

      # Login screen
      displayManager = {
        lightdm = {
          enable = config.services.xserver.enable;

          # Make the login screen dark
          greeters.gtk.theme.name = config.gui.gtkTheme;

        };
      };

    };

    environment.systemPackages = with pkgs;
      [
        xclip # Clipboard
      ];

    home-manager.users.${config.user}.programs.fish.shellAliases = {
      pbcopy = "xclip -selection clipboard -in";
      pbpaste = "xclip -selection clipboard -out";
    };

  };

}
