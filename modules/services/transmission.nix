{ config, pkgs, lib, ... }: {

  imports = [ ./wireguard.nix ./secrets.nix ];

  options = {
    transmissionServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Transmission";
    };
  };

  config = let
    namespace = config.networking.wireguard.interfaces.wg0.interfaceNamespace;
    vpnIp = lib.strings.removeSuffix "/32"
      (builtins.head config.networking.wireguard.interfaces.wg0.ips);
  in {

    # Setup transmission
    services.transmission = {
      enable = true;
      settings = {
        port-forwarding-enabled = false;
        rpc-authentication-required = true;
        rpc-port = 9091;
        rpc-bind-address = "0.0.0.0";
        rpc-username = config.user;
        rpc-host-whitelist = config.transmissionServer;
        rpc-host-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,${vpnIp}";
        rpc-whitelist-enabled = true;
      };
      credentialsFile = config.secrets.transmission.dest;
    };

    # Bind transmission to wireguard namespace
    systemd.services.transmission = {
      bindsTo = [ "netns@${namespace}.service" ];
      requires = [ "network-online.target" "transmission-secret.service" ];
      after = [ "wireguard-wg0.service" "transmission-secret.service" ];
      unitConfig.JoinsNamespaceOf = "netns@${namespace}.service";
      serviceConfig.NetworkNamespacePath = "/var/run/netns/${namespace}";
    };

    # Create reverse proxy for web UI
    caddyRoutes = [{
      match = [{ host = [ config.transmissionServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:9091"; }];
      }];
    }];

    # Allow inbound connections to reach namespace
    systemd.services.transmission-web-netns = {
      description = "Forward to transmission in wireguard namespace";
      requires = [ "transmission.service" ];
      after = [ "transmission.service" ];
      serviceConfig = {
        Restart = "on-failure";
        TimeoutStopSec = 300;
      };
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.iproute2}/bin/ip netns exec ${namespace} ${pkgs.iproute2}/bin/ip link set dev lo up
        ${pkgs.socat}/bin/socat tcp-listen:9091,fork,reuseaddr exec:'${pkgs.iproute2}/bin/ip netns exec ${namespace} ${pkgs.socat}/bin/socat STDIO "tcp-connect:${vpnIp}:9091"',nofork
      '';
    };

    # Create credentials file for transmission
    secrets.transmission = {
      source = ../../private/transmission.json.age;
      dest = "/var/lib/private/transmission.json";
      owner = "transmission";
      group = "transmission";
    };

  };

}
