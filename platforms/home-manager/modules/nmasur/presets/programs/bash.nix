{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.bash;
in

{

  options.nmasur.presets.programs.bash.enable = lib.mkEnableOption "Bash shell";

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = config.programs.fish.shellAliases;
      initExtra = "";
      profileExtra = "";
    };

    programs.starship.enableBashIntegration = false;
    programs.zoxide.enableBashIntegration = true;
    programs.fzf.enableBashIntegration = true;

  };
}
