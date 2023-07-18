{ pkgs, ... }: {

  config = {

    services.bind = {

      cacheNetworks = [ "192.168.0.0/16" ];

      forwarders = [ "1.1.1.1" "1.0.0.1" ];

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
            stream          A       192.168.0.218
          '';
        };
      };

    };

  };

}
