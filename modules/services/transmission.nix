{ config, pkgs, lib, ... }:

let credentialsFile = "/var/lib/private/transmission.json";

in {

  imports = [ ./wireguard.nix ];

  options = {
    transmissionServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Transmission";
    };
  };

  config = let
    namespace = config.networking.wireguard.interfaces.wg0.interfaceNamespace;
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
        rpc-whitelist-enabled = false;
      };
      credentialsFile = credentialsFile;
    };

    # Bind transmission to wireguard namespace
    systemd.services.transmission = {
      bindsTo = [ "netns@${namespace}.service" ];
      requires = [ "network-online.target" ];
      after = [ "wireguard-wg0.service" ];
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
        ${pkgs.socat}/bin/socat tcp-listen:9091,fork,reuseaddr exec:'${pkgs.iproute2}/bin/ip netns exec ${namespace} ${pkgs.socat}/bin/socat STDIO "tcp-connect:10.66.13.200:9091"',nofork
      '';
    };

    # Create credentials file for transmission
    systemd.services.transmission-creds = {
      requiredBy = [ "transmission.service" ];
      before = [ "transmission.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ ! -f "${credentialsFile}" ]; then
          mkdir --parents ${builtins.dirOf credentialsFile}
          ${pkgs.age}/bin/age --decrypt \
            --identity ${config.identityFile} \
            --output ${credentialsFile} \
            ${builtins.toString ../../private/transmission.json.age}
          chown transmission:transmission ${credentialsFile}
          chmod 0700 ${credentialsFile}
        fi
      '';
    };

  };

}
