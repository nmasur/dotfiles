{ config, pkgs, lib, ... }: {

  options = {
    transmissionServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for Transmission";
      default = null;
    };
  };

  config = let
    namespace = config.networking.wireguard.interfaces.wg0.interfaceNamespace;
    vpnIp = lib.strings.removeSuffix "/32"
      (builtins.head config.networking.wireguard.interfaces.wg0.ips);
  in lib.mkIf (config.transmissionServer != null) {

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
        rpc-whitelist-enabled = config.wireguard.enable;
      };
      credentialsFile = config.secrets.transmission.dest;
    };

    # Bind transmission to wireguard namespace
    systemd.services.transmission = lib.mkIf config.wireguard.enable {
      bindsTo = [ "netns@${namespace}.service" ];
      requires = [ "network-online.target" "transmission-secret.service" ];
      after = [ "wireguard-wg0.service" "transmission-secret.service" ];
      unitConfig.JoinsNamespaceOf = "netns@${namespace}.service";
      serviceConfig.NetworkNamespacePath = "/var/run/netns/${namespace}";
    };

    # Create reverse proxy for web UI
    caddy.routes = lib.mkAfter [{
      group = if (config.hostnames.download == config.transmissionServer) then
        "download"
      else
        "transmission";
      match = [{
        host = [ config.transmissionServer ];
        path = [ "/transmission*" ];
      }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:9091"; }];
      }];
    }];

    # Caddy and Transmission both try to set rmem_max for larger UDP packets.
    # We will choose Transmission's recommendation (4 MB).
    boot.kernel.sysctl."net.core.rmem_max" = 4194304;

    # Allow inbound connections to reach namespace
    systemd.services.transmission-web-netns = lib.mkIf config.wireguard.enable {
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
      source = ../../../private/transmission.json.age;
      dest = "${config.secretsDirectory}/transmission.json";
      owner = "transmission";
      group = "transmission";
    };

  };

}
