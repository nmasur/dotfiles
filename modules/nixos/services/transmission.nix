# Transmission is a bittorrent client, which can run in the background for
# automated downloads with a web GUI.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  config =
    let
      namespace = config.networking.wireguard.interfaces.wg0.interfaceNamespace;
      vpnIp = lib.strings.removeSuffix "/32" (
        builtins.head config.networking.wireguard.interfaces.wg0.ips
      );
    in
    lib.mkIf config.services.transmission.enable {

      # Setup transmission
      services.transmission = {
        settings = {
          port-forwarding-enabled = false;
          rpc-authentication-required = true;
          rpc-port = 9091;
          rpc-bind-address = "0.0.0.0";
          rpc-username = config.user;
          # This is a salted hash of the real password
          # https://github.com/tomwijnroks/transmission-pwgen
          rpc-password = "{c4c5145f6e18bcd3c7429214a832440a45285ce26jDOBGVW";
          rpc-host-whitelist = config.hostnames.transmission;
          rpc-host-whitelist-enabled = true;
          rpc-whitelist = lib.mkDefault "127.0.0.1"; # Overwritten by Cloudflare
          rpc-whitelist-enabled = true;
        };
      };

      # Configure Cloudflare DNS to point to this machine
      services.cloudflare-dyndns.domains = [ config.hostnames.transmission ];

      # Bind transmission to wireguard namespace
      systemd.services.transmission = lib.mkIf config.wireguard.enable {
        bindsTo = [ "netns@${namespace}.service" ];
        requires = [
          "network-online.target"
          "transmission-secret.service"
        ];
        after = [
          "wireguard-wg0.service"
          "transmission-secret.service"
        ];
        unitConfig.JoinsNamespaceOf = "netns@${namespace}.service";
        serviceConfig.NetworkNamespacePath = "/var/run/netns/${namespace}";
      };

      # Create reverse proxy for web UI
      caddy.routes =
        let
          # Set if the download domain is the same as the Transmission domain
          useDownloadDomain = config.hostnames.download == config.hostnames.transmission;
        in
        lib.mkAfter [
          {
            group = if useDownloadDomain then "download" else "transmission";
            match = [
              {
                host = [ config.hostnames.transmission ];
                path = if useDownloadDomain then [ "/transmission*" ] else null;
              }
            ];
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [
                  { dial = "localhost:${builtins.toString config.services.transmission.settings.rpc-port}"; }
                ];
              }
            ];
          }
        ];

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
    };
}
