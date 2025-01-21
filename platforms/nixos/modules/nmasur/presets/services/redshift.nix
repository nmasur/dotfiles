{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.redshift;
in

{

  options.nmasur.presets.services.redshift.enable = lib.mkEnableOption "Redshift light adjuster";

  config = lib.mkIf cfg.enable {

    # Reduce blue light at night
    services.redshift = {
      enable = true;
      brightness = {
        day = "1.0";
        night = "1.0";
      };
    };

    # Service to determine location for time zone
    # This is required for redshift which depends on the location provider
    services.geoclue2.enable = true;
    services.geoclue2.enableWifi = false; # Breaks when it can't connect
    location = {
      provider = "geoclue2";
    };

  };
}
