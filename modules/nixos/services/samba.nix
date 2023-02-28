{ config, lib, ... }: {

  options = { samba.enable = lib.mkEnableOption "Enable Samba sharing."; };

  config = lib.mkIf (config.samba.enable) {

    services.samba.enable = true;
    services.samba.shares.video = {
      path = "/data/video";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "force user" = config.user;
      "force group" = config.user;
      comment = "Movies and TV";
    };

  };

}
