{ config, pkgs, lib, identity, gui, ... }: {

  config = lib.mkIf gui.enable {

    # Enable the X11 windowing system.
    services.xserver = {
      enable = gui.enable;

      # Enable touchpad support
      libinput.enable = true;

      # Login screen
      displayManager = {
        lightdm = {
          enable = config.services.xserver.enable;

          # Make the login screen dark
          greeters.gtk.theme.name = gui.gtkTheme;

        };
      };

    };

    environment.systemPackages = with pkgs;
      [
        xclip # Clipboard
      ];

    home-manager.users.${identity.user}.programs.fish.shellAliases = {
      pbcopy = "xclip -selection clipboard -in";
      pbpaste = "xclip -selection clipboard -out";
    };

  };

}
