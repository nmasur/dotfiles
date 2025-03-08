{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.profiles.gui;
in

{

  options.nmasur.profiles.gui.enable = lib.mkEnableOption "GUI machine";

  config = lib.mkIf cfg.enable {

    nmasur.presets.services.kanata.enable = lib.mkDefault true;
    nmasur.presets.services.lightdm.enable = lib.mkDefault true;

    # Mouse customization
    services.ratbagd.enable = lib.mkDefault true;

    environment.systemPackages = [
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
    services.libinput.enable = lib.mkDefault true;

    services.xserver = {

      enable = lib.mkDefault true;
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

    users.users.${username} = {
      # Grant main user access to external monitors
      extraGroups = [ "i2c" ];

      # Automatically create a password to start
      hashedPassword = lib.mkDefault (lib.fileContents ../../../../../misc/password.sha512);
    };

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

    # TODO: can we get rid of this?
    # environment.sessionVariables = {
    #   GTK_THEME = config.gtk.theme.name;
    # };

  };
}
