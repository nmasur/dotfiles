{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.bat;
in

{

  options.nmasur.presets.programs.bat.enable = lib.mkEnableOption "Bat text pager";

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true; # cat replacement
      config = {
        theme = config.theme.colors.batTheme;
        pager = "less -R"; # Don't auto-exit if one screen
      };
    };
  };
}
