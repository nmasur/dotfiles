{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf pkgs.stdenv.isLinux {

    services.tzupdate.enable = true;

    # Service to determine location for time zone
    # This is required for redshift which depends on the location provider
    services.geoclue2.enable = true;
    services.geoclue2.enableWifi = false; # Breaks when it can't connect
    location = {
      provider = "geoclue2";
    };
  };
}
