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
  };

}
