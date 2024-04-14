# Bind is a DNS service. This allows me to resolve public domains locally so
# when I'm at home, I don't have to travel over the Internet to reach my
# server.

# To set this on all home machines, I point my router's DNS resolver to the
# local IP address of the machine running this service (swan).

{
  config,
  pkgs,
  lib,
  ...
}:

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
in
{

  config = lib.mkIf config.services.bind.enable {

    # Normally I block all requests not coming from Cloudflare, so I have to also
    # allow my local network.
    caddy.cidrAllowlist = [ "192.168.0.0/16" ];

    services.bind = {

      # Allow requests coming from these IPs. This way I don't somehow get
      # spammed with DNS requests coming from the Internet.
      cacheNetworks = [
        "127.0.0.0/24"
        "192.168.0.0/16"
        "::1/128" # Required because IPv6 loopback now added to resolv.conf
        # (see: https://github.com/NixOS/nixpkgs/pull/302228)
      ];

      # When making normal DNS requests, forward them to Cloudflare to resolve.
      forwarders = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      ipv4Only = false;

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

    # We must allow DNS traffic to hit our machine as well
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    # Set our own nameservers to ourselves
    networking.nameservers = [
      "127.0.0.1"
      "::1"
    ];
  };
}
