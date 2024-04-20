{ config, lib, ... }:
{

  options.mail.himalaya.enable = lib.mkEnableOption "Himalaya email.";

  config = lib.mkIf config.mail.himalaya.enable {

    home-manager.users.${config.user} = {

      programs.himalaya = {
        enable = true;
      };
      accounts.email.accounts.home.himalaya = {
        enable = true;
        settings = {
          downloads-dir = config.userDirs.download;
          smtp-insecure = true;
        };
      };

      programs.fish.shellAbbrs = {
        hi = "himalaya";
      };
    };
  };
}
