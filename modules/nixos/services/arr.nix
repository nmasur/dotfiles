{ config, lib, ... }: {

  options = { arrs.enable = lib.mkEnableOption "Arr services"; };

  config = lib.mkIf config.arrs.enable {

    services = {
      bazarr = {
        enable = true;
        group = "media";
      };
      jellyseerr.enable = true;
      prowlarr.enable = true;
      sabnzbd = {
        enable = true;
        group = "media";
        configFile = "/data/downloads/sabnzbd/sabnzbd.ini";
      };
      sonarr = {
        enable = true;
        group = "media";
      };
      radarr = {
        enable = true;
        group = "media";
      };
    };

    users.groups.media = { };
    users.users.${config.user}.extraGroups = [ "media" ];
    users.users.sabnzbd.homeMode = "0770";

    unfreePackages = [ "unrar" ]; # Required for sabnzbd

    # Requires updating the base_url config value in each service
    # If you try to rewrite the URL, the service won't redirect properly
    caddy.routes = [
      {
        group = "download";
        match = [{
          host = [ config.hostnames.download ];
          path = [ "/sonarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:8989"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.hostnames.download ];
          path = [ "/radarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:7878"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.hostnames.download ];
          path = [ "/prowlarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:9696"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.hostnames.download ];
          path = [ "/bazarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:6767"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.hostnames.download ];
          path = [ "/sabnzbd*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:8085"; }];
        }];
      }
      {
        group = "download";
        match = [{ host = [ config.hostnames.download ]; }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:5055"; }];
        }];
      }
    ];

  };

}
