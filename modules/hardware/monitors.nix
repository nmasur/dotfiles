{ pkgs, identity, ... }: {

  # Timezone required for Redshift schedule
  imports = [ ../system/timezone.nix ];

  environment.systemPackages = with pkgs;
    [
      ddcutil # Monitor brightness control
    ];

  # Reduce blue light at night
  services.redshift = {
    enable = true;
    brightness = {
      day = "1.0";
      night = "1.0";
    };
  };

  # Detect monitors (brightness)
  hardware.i2c.enable = true;

  # Grant user access to external monitors
  users.users.${identity.user}.extraGroups = [ "i2c" ];

  services.xserver.displayManager = {

    # Put the login screen on the left monitor
    lightdm.greeters.gtk.extraConfig = ''
      active-monitor=0
    '';

    # Set up screen position and rotation
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

}
