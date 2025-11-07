{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.chawan;
in

{

  options.nmasur.presets.programs.chawan.enable = lib.mkEnableOption "chawan TUI web browser";

  config = lib.mkIf cfg.enable {

    # Set Chawan as the default app for manual pages
    home.sessionVariables = {
      MANPAGER = "${pkgs.chawan}/bin/mancha";
    };

  };

}
