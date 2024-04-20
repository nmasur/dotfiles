# Keybase is an encrypted communications tool with a synchronized encrypted
# filestore that can be mounted onto a machine's filesystem.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.keybase.enable = lib.mkEnableOption "Keybase.";

  config = lib.mkIf config.keybase.enable {

    home-manager.users.${config.user} = lib.mkIf config.keybase.enable {

      services.keybase.enable = true;
      services.kbfs = {
        enable = true;
        mountPoint = "keybase";
      };

      # https://github.com/nix-community/home-manager/issues/4722
      systemd.user.services.kbfs.Service.PrivateTmp = lib.mkForce false;

      home.packages = [ (lib.mkIf config.gui.enable pkgs.keybase-gui) ];
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
  };
}
