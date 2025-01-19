{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf config.gui.enable {

    environment.systemPackages = with pkgs; [
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

    # Detect monitors (brightness) for ddcutil
    hardware.i2c.enable = true;

    # Grant main user access to external monitors
    users.users.${config.user}.extraGroups = [ "i2c" ];

    services.xserver.displayManager = {

      # Put the login screen on the left monitor
      lightdm.greeters.gtk.extraConfig = ''
        active-monitor=0
      '';

      # Set up screen position and rotation
      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-1 \
                                            --primary \
                                            --rotate normal \
                                            --mode 2560x1440 \
                                            --rate 165 \
                                        --output DisplayPort-2 \
                                            --right-of DisplayPort-1 \
                                            --rotate left \
                                        --output DVI-0 --off \
                                        --output DVI-1 --off \
                                        || echo "xrandr failed"
      '';
    };
  };
}
