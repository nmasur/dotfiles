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

    programs.chawan = {
      enable = true;
      settings = {
        external.copy-cmd = if pkgs.stdenv.isLinux then "xclip -selection clipboard -in" else "pbcopy";
      };
    };

    # Set Chawan as the default app for manual pages
    home.sessionVariables = {
      MANPAGER = "${lib.getExe pkgs.chawan} -T text/x-ansi";
    };

    programs.fish.shellAbbrs.man = "mancha";

  };

}
