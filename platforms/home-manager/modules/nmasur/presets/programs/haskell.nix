{ config, lib, ... }:
let
  cfg = config.nmasur.presets.programs.haskell;
in
{

  options.nmasur.presets.programs.haskell.enable =
    lib.mkEnableOption "Haskell programming language config.";

  config = lib.mkIf cfg.enable {

    # Binary Cache for Haskell.nix
    nix.settings.trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    nix.settings.substituters = [ "https://cache.iog.io" ];
  };
}
