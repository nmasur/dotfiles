{ config, pkgs, ... }:

let privateKeyFile = "/private/wireguard/wg0";

in {

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {

        # The local IPs for this machine within the Wireguard network
        # Any inbound traffic bound for these IPs should be kept on localhost
        ips = [ "10.66.13.200/32" "fc00:bbbb:bbbb:bb01::3:dc7/128" ];

        # Establishes identity of this machine
        generatePrivateKeyFile = false;
        privateKeyFile = privateKeyFile;

        peers = [{

          # Identity of Wireguard target peer (VPN)
          publicKey = "bOOP5lIjqCdDx5t+mP/kEcSbHS4cZqE0rMlBI178lyY=";

          # Which outgoing IP ranges should be sent through Wireguard
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];

          # The public internet address of the target peer
          endpoint = "86.106.143.132:51820";

          # Send heartbeat signal within the network
          persistentKeepalive = 25;

        }];

        # Namespaces
        interfaceNamespace = "wg";
        # socketNamespace = "wg";

      };
    };
  };

  # Create namespace for Wireguard
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  # Private key file for wireguard
  systemd.services.wireguard-private-key = {
    wantedBy = [ "wireguard-wg0.service" ];
    requiredBy = [ "wireguard-wg0.service" ];
    before = [ "wireguard-wg0.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir --parents --mode 0755 ${builtins.dirOf privateKeyFile}
      if [ ! -f "${privateKeyFile}" ]; then
        ${pkgs.age}/bin/age --decrypt \
          --identity ${config.identityFile} \
          --output ${privateKeyFile} \
          ${builtins.toString ../../private/wireguard.age}
        chmod 0700 ${privateKeyFile}
      fi
    '';
  };

}
