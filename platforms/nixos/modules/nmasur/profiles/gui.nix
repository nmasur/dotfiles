{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.gui;
in

{

  options.nmasur.profiles.gui.enable = lib.mkEnableOption "GUI machine";

  config = lib.mkIf cfg.enable {

    # Mouse customization
    services.ratbagd.enable = lib.mkDefault true;

    environment.systemPackages = lib.mkDefault [
      pkgs.libratbag # Mouse adjustments
      pkgs.piper # Mouse adjustments GUI
      pkgs.ddcutil # Monitor brightness control
    ];

    services.libinput.mouse = {
      # Disable mouse acceleration
      accelProfile = lib.mkDefault "flat";
      accelSpeed = lib.mkDefault "1.15";
    };

    # Enable touchpad support
    services.libinput.enable = true;

    services.xserver = {

      xkb.layout = lib.mkDefault "us";

      # Keyboard responsiveness
      autoRepeatDelay = lib.mkDefault 250;
      autoRepeatInterval = lib.mkDefault 40;

      windowManager = {
        i3 = {
          enable = lib.mkDefault true;
        };
      };

    };

    # Detect monitors (brightness) for ddcutil
    hardware.i2c.enable = lib.mkDefault true;

    # Grant main user access to external monitors
    users.users.${config.user}.extraGroups = lib.mkDefault [ "i2c" ];

    services.xserver.displayManager = {

      # Put the login screen on the left monitor
      lightdm.greeters.gtk.extraConfig = lib.mkDefault ''
        active-monitor=0
      '';

      # Set up screen position and rotation
      setupCommands = lib.mkDefault ''
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

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

    # Make the login screen dark
    services.xserver.displayManager.lightdm.greeters.gtk.theme = {
      name = config.gtk.theme.name;
      package = config.gtk.theme.package;
    };

    environment.sessionVariables = {
      GTK_THEME = config.gtk.theme.name;
    };

  };
}
