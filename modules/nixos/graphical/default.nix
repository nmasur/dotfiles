{ lib, ... }: {

  imports = [
    ./dunst.nix
    ./fonts.nix
    ./gtk.nix
    ./i3.nix
    ./picom.nix
    ./polybar.nix
    ./rofi.nix
    ./xorg.nix
  ];

  options = {

    altTabCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for choosing windows";
    };
    audioSwitchCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for switching audio sink";
    };
    brightnessCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for adjusting brightness";
    };
    calculatorCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for quick calculations";
    };
    launcherCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for launching";
    };
    lockScreenCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use to lock the screen";
    };
    powerCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for power options menu";
    };
    systemdSearch = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for interacting with systemd";
    };
    terminal = lib.mkOption {
      type = lib.types.str;
      description = "Package to use for graphical terminal";
    };
    toggleBarCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to hide and show the status bar.";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Wallpaper background image file";
    };

  };

}
