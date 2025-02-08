{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.himalaya;
in

{

  options.nmasur.presets.programs.himalaya.enable = lib.mkEnableOption "Himalaya email CLI";

  config = lib.mkIf cfg.enable {

    programs.himalaya = {
      enable = true;
    };
    accounts.email.accounts.home.himalaya = {
      enable = true;
      settings = {
        downloads-dir = config.xdg.userDirs.download;
        smtp-insecure = true;
      };
    };

    programs.fish.shellAbbrs = {
      hi = "himalaya";
    };

  };
}
