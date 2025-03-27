# Keybase is an encrypted communications tool with a synchronized encrypted
# filestore that can be mounted onto a machine's filesystem.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.keybase;
in

{

  options.nmasur.presets.services.keybase.enable = lib.mkEnableOption "Keybase encryption tool";

  config = lib.mkIf cfg.enable {

    services.keybase.enable = true;
    services.kbfs = {
      enable = true;
      mountPoint = "keybase";
    };

    home.packages = [ (lib.mkIf config.nmasur.profiles.linux-gui.enable pkgs.keybase-gui) ];
    home.file =
      let
        ignorePatterns = ''
          keybase/
          kbfs/'';
      in
      {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
      };
  };
}
