{ ... }: {

  # Service to determine location for time zone
  services.geoclue2.enable = true;
  location = { provider = "geoclue2"; };

  # Enable local time based on time zone
  services.localtime.enable = true;

}
