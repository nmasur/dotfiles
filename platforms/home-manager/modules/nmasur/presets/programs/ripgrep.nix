{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.ripgrep;
in

{

  options.nmasur.presets.programs.ripgrep = {
    enable = lib.mkEnableOption "Ripgrep search tool";
    ignorePatterns = ''
      !.env*
      !.github/
      !.gitignore
      !*.tfvars
      .terraform/
      .target/
      /Library/'';
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];

    home.file = {
      ".rgignore".text = cfg.ignorePatterns;
    };
  };
}
