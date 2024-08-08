{
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ./chiaki.nix
    ./dwarf-fortress.nix
    ./legendary.nix
    ./lutris.nix
    ./minecraft-server.nix
    ./moonlight.nix
    ./ryujinx.nix
    ./steam.nix
  ];

  options.gaming.enable = lib.mkEnableOption "Enable gaming features.";

  config = lib.mkIf (config.gaming.enable && pkgs.stdenv.isLinux) {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    programs.gamemode.enable = true;
  };
}
