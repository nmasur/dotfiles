{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.postgresql;
in
{

  options.nmasur.presets.services.postgresql.enable = lib.mkEnableOption "Postgresql database";

  services.postgresql = lib.mkIf cfg.enable {
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

}
