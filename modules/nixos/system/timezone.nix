{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf pkgs.stdenv.isLinux {

    # Service to determine location for time zone
    services.geoclue2.enable = true;
    services.geoclue2.enableWifi = false; # Breaks when it can't connect
    location = {
      provider = "geoclue2";
    };

    # Enable local time based on time zone
    services.localtimed.enable = true;

    # Required to get localtimed to talk to geoclue2
    services.geoclue2.appConfig.localtimed.isSystem = true;
    services.geoclue2.appConfig.localtimed.isAllowed = true;

    # Fix "Failed to set timezone"
    # https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-1484030107
    services.geoclue2.enableDemoAgent = lib.mkForce true;
  };
}
