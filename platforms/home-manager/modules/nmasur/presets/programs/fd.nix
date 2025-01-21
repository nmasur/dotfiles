{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fd;
in

{

  options.nmasur.presets.programs.fd.enable = lib.mkEnableOption "fd file search tool";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fd ];
    xdg.configFile."fd/ignore".text = config.nmasur.presets.programs.ripgrep.ignorePatterns;
  };
}
