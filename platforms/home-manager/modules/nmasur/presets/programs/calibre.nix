{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.calibre;
in

{

  options.nmasur.presets.programs.calibre.enable = lib.mkEnableOption "Calibre e-book manager";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.calibre ];
    home.sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = 1;
    };
  };
}
