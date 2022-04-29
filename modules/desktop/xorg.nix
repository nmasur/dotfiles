{ pkgs, user, gui, ... }:

let gtkTheme = "Adwaita-dark";

in {

  # Enable the X11 windowing system.
  services.xserver = {
    enable = gui;

    # Enable touchpad support
    libinput.enable = true;

    # Login screen
    displayManager = {
      lightdm = {
        enable = gui;

        # Make the login screen dark
        greeters.gtk.theme.name = gtkTheme;

      };
    };

  };

  environment.systemPackages = with pkgs;
    [
      xclip # Clipboard
    ];

  home-manager.users.${user}.gtk = {
    enable = true;
    theme = { name = gtkTheme; };
  };

}

