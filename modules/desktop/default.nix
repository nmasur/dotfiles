{ lib, ... }: {

  imports = [
    ./xorg.nix
    ./fonts.nix
    ./i3.nix
    ./polybar.nix
    ./picom.nix
    # ./dmenu.nix
    ./rofi.nix
  ];

  options = {
    launcherCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to use for launching";
    };
  };

}
