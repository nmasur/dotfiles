{ lib, gui, ... }: {

  imports = [
    ./audio.nix
    ./boot.nix
    ./keyboard.nix
    ./monitors.nix
    ./mouse.nix
    ./networking.nix
  ];

}
