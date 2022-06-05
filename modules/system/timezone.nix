{ ... }: {

  # Service to determine location for time zone
  services.geoclue2.enable = true;
  services.geoclue2.enableWifi = false; # Breaks when it can't connect
  location = { provider = "geoclue2"; };

  # Enable local time based on time zone
  services.localtimed.enable = true;

  # Required to get localtimed to talk to geoclue2
  services.geoclue2.appConfig.localtimed.isSystem = true;
  services.geoclue2.appConfig.localtimed.isAllowed = true;

}
