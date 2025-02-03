{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zoxide;
in

{

  options.nmasur.presets.programs.zoxide.enable = lib.mkEnableOption "zoxide smart cd replacement";

  config = lib.mkIf cfg.enable {

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

  };
}
