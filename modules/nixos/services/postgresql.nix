{
  config,
  pkgs,
  lib,
  ...
}:
{

  services.postgresql = {
    package = pkgs.postgresql_15;
    settings = { };
    authentication = ''
      local all postgres peer map=root
      local all admin peer map=admin
    '';
    identMap = ''
      root      postgres          postgres
      root      root              postgres
      admin     ${config.user}    admin
    '';
    ensureUsers = [
      {
        name = "admin";
        ensureClauses = {
          createdb = true;
          createrole = true;
          login = true;
        };
      }
    ];
  };

  home-manager.users.${config.user}.home.packages = lib.mkIf config.services.postgresql.enable [
    pkgs.pgcli # Postgres client with autocomplete
  ];
}
