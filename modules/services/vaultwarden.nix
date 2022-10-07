{ config, pkgs, lib, ... }: {

  options = {

    vaultwardenServer = lib.mkOption {
      description = "Hostname for Vaultwarden.";
      type = lib.types.str;
    };

  };

  config = {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = config.vaultwardenServer;
        SIGNUPS_ALLOWED = false;
      };
      environmentFile = null;
      dbBackend = "sqlite";
    };
  };

}
