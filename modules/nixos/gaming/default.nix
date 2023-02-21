{ config, pkgs, lib, ... }: {

  imports = [
    ./leagueoflegends.nix
    ./legendary.nix
    ./lutris.nix
    ./minecraft-server.nix
    ./steam.nix
  ];

  options.gaming.enable = lib.mkEnableOption "Enable gaming features.";

  config = lib.mkIf (config.gaming.enable && pkgs.stdenv.isLinux) {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
