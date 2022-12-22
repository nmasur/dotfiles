{ lib, ... }: {

  imports = [
    ./audio.nix
    ./boot.nix
    ./keyboard.nix
    ./monitors.nix
    ./mouse.nix
    ./networking.nix
    ./sleep.nix
    ./wifi.nix
  ];

  options = {
    physical = lib.mkEnableOption "Whether this machine is a physical device.";
    server = lib.mkEnableOption "Whether this machine is a server.";
  };

}
