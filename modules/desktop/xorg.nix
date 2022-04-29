{ pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Enable touchpad support
    libinput.enable = true;

    # Disable mouse acceleration
    libinput.mouse.accelProfile = "flat";
    libinput.mouse.accelSpeed = "1.15";

    # Keyboard responsiveness
    autoRepeatDelay = 250;
    autoRepeatInterval = 40;

    # Configure keymap in X11
    layout = "us";
    xkbOptions = "eurosign:e,caps:swapescape";

    # Login screen
    displayManager = {
      lightdm = {
        enable = true;

        # Make the login screen dark
        greeters.gtk.theme.name = "Adwaita-dark";

        # Put the login screen on the left monitor
        greeters.gtk.extraConfig = ''
          active-monitor=0
        '';
      };
      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-0 \
                                            --mode 1920x1200 \
                                            --pos 1920x0 \
                                            --rotate left \
                                        --output HDMI-0 \
                                            --primary \
                                            --mode 1920x1080 \
                                            --pos 0x559 \
                                            --rotate normal \
                                        --output DVI-0 --off \
                                        --output DVI-1 --off \
      '';
    };

  };

}

