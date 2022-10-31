{ config, pkgs, lib, ... }:

let

  gtkTheme = {
    name = config.gui.gtk.theme.name;
    package = pkgs.${config.gui.gtk.theme.package};
  };

in {

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
          background = config.gui.wallpaper;

          # Make the login screen dark
          greeters.gtk.theme = gtkTheme;

          # Show default user
          extraSeatDefaults = ''
            greeter-hide-users = false
          '';

        };
      };

    };

    environment.systemPackages = with pkgs;
      [
        xclip # Clipboard
      ];

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

    environment.sessionVariables = { GTK_THEME = config.gui.gtk.theme.name; };

    home-manager.users.${config.user} = {

      programs.fish.shellAliases = {
        pbcopy = "xclip -selection clipboard -in";
        pbpaste = "xclip -selection clipboard -out";
      };

      gtk = let gtkExtraConfig = { gtk-application-prefer-dark-theme = true; };
      in {
        enable = true;
        theme = gtkTheme;
        gtk3.extraConfig = gtkExtraConfig;
        gtk4.extraConfig = gtkExtraConfig;
      };

    };

  };

}
