{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.python;
in
{

  options.nmasur.presets.programs.python.enable = lib.mkEnableOption "Python programming language.";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.pyright # Python language server
      pkgs.black # Python formatter
      pkgs.python310Packages.flake8 # Python linter
    ];

    programs.fish.shellAbbrs = {
      py = "python3";
    };
  };
}
