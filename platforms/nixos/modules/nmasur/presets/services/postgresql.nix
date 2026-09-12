{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.postgresql;
in
{

  options.nmasur.presets.services.postgresql.enable = lib.mkEnableOption "Postgresql database";
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      settings = { };
      authentication = ''
        local all postgres peer map=root
        local all admin peer map=admin
      '';
      identMap = ''
        root      postgres          postgres
        root      root              postgres
        admin     ${username}    admin
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

    # Refresh collation version if glibc was upgraded across system releases
    systemd.services.postgresql-setup = {
      preStart = ''
        while ! ${config.services.postgresql.package}/bin/psql -d postgres -tAc 'SELECT 1' >/dev/null 2>&1; do
          if ! systemctl is-active --quiet postgresql.service; then break; fi
          sleep 0.1
        done
        ${config.services.postgresql.package}/bin/psql -d postgres -tAc 'ALTER DATABASE template1 REFRESH COLLATION VERSION;' || true
        ${config.services.postgresql.package}/bin/psql -d postgres -tAc 'ALTER DATABASE postgres REFRESH COLLATION VERSION;' || true
      '';
    };
  };

}
