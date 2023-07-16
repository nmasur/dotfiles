{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.services.jellyfin.enable {

    services.jellyfin.group = "media";
    users.users.jellyfin = { isSystemUser = true; };

    caddy.routes = [
      {
        match = [{
          host = [ config.hostnames.stream ];
          path = [ "/metrics*" ];
        }];
        handle = [{
          handler = "static_response";
          status_code = "403";
        }];
      }
      {
        match = [{ host = [ config.hostnames.stream ]; }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:8096"; }];
        }];
      }
    ];

    # Create videos directory, allow anyone in Jellyfin group to manage it
    systemd.tmpfiles.rules = [
      "d /var/lib/jellyfin 0775 jellyfin media"
      "d /var/lib/jellyfin/library 0775 jellyfin media"
    ];

    # Enable VA-API for hardware transcoding
    hardware.opengl = {
      enable = true;
      driSupport = true;
      extraPackages = [ pkgs.libva ];
    };
    environment.systemPackages = [ pkgs.libva-utils ];
    environment.variables = {
      # VAAPI and VDPAU config for accelerated video.
      # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
      "VDPAU_DRIVER" = "radeonsi";
      "LIBVA_DRIVER_NAME" = "radeonsi";
    };
    users.users.jellyfin.extraGroups =
      [ "render" "video" ]; # Access to /dev/dri

    # Requires MetricsEnable is true in /var/lib/jellyfin/config/system.xml
    prometheus.scrapeTargets = [ "127.0.0.1:8096" ];

  };

}
