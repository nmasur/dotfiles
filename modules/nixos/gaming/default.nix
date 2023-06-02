{ config, pkgs, lib, ... }: {

  imports = [
    ./chiaki.nix
    ./dwarf-fortress.nix
    ./leagueoflegends.nix
    ./legendary.nix
    ./lutris.nix
    ./minecraft-server.nix
    ./ryujinx.nix
    ./steam.nix
  ];

  options.gaming.enable = lib.mkEnableOption "Enable gaming features.";

  config = lib.mkIf (config.gaming.enable && pkgs.stdenv.isLinux) {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    programs.gamemode.enable = true;
  };
}
