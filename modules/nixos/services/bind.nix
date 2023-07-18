{ config, pkgs, lib, ... }:

let

  localIp = "192.168.1.218";
  localServices = [
    config.hostnames.stream
    config.hostnames.content
    config.hostnames.books
    config.hostnames.download
  ];
  mkRecord = service: "${service}       A       ${localIp}";
  localRecords = lib.concatLines (map mkRecord localServices);

in {

  config = lib.mkIf config.services.bind.enable {

    caddy.cidrAllowlist = [ "192.168.0.0/16" ];

    services.bind = {
      cacheNetworks = [ "127.0.0.0/24" "192.168.0.0/16" ];
      forwarders = [ "1.1.1.1" "1.0.0.1" ];
      ipv4Only = true;

      # Use rpz zone as an override
      extraOptions = ''response-policy { zone "rpz"; };'';

      zones = {
        rpz = {
          master = true;
          file = pkgs.writeText "db.rpz" ''
            $TTL 60  ; 1 minute
            @       IN      SOA     localhost. root.localhost. (
                                    2023071800      ; serial
                                    1h              ; refresh
                                    30m             ; retry
                                    1w              ; expire
                                    30m             ; minimum ttl
                                    )
                    IN      NS      localhost.
            localhost       A       127.0.0.1
            ${localRecords}
          '';
        };
      };

    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

  };

}
