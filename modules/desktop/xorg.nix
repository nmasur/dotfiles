{ pkgs, gui, ... }: {

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
        greeters.gtk.theme.name = "Adwaita-dark";

      };
    };

  };

  environment.systemPackages = with pkgs;
    [
      xclip # Clipboard
    ];

}

