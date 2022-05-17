{ ... }: {

  # Service to determine location for time zone
  services.geoclue2.enable = true;
  services.geoclue2.enableWifi = false; # Breaks when it can't connect
  location = { provider = "geoclue2"; };

  # Enable local time based on time zone
  services.localtime.enable = true;

}
