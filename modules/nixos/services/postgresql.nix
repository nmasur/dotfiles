{ config, pkgs, lib, ... }: {

  services.postgresql = {
    package = pkgs.postgresql_15;
    settings = { };
    identMap = "";
    ensureUsers = [{
      name = config.user;
      ensureClauses = {
        createdb = true;
        createrole = true;
        login = true;
      };
    }];
  };

  home-manager.users.${config.user}.home.packages =
    lib.mkIf config.services.postgresql.enable [
      pkgs.pgcli # Postgres client with autocomplete
    ];

}
