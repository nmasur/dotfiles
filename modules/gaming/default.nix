{ config, ... }: {

  imports = [ ./leagueoflegends.nix ./lutris.nix ./steam.nix ./legendary.nix ];

  config = {
    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
}
