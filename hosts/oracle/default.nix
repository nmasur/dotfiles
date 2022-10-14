{ nixpkgs, home-manager, globals, ... }:

# System configuration for an Oracle free server

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/

nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { };
  modules = [
    (removeAttrs globals [ "mailServer" ])
    home-manager.nixosModules.home-manager
    {
      gui.enable = false;
      colorscheme = (import ../../modules/colorscheme/gruvbox);

      # FQDNs for various services
      networking.hostName = "oracle";
      bookServer = "books.masu.rs";
      streamServer = "stream.masu.rs";
      nextcloudServer = "cloud.masu.rs";
      transmissionServer = "download.masu.rs";
      metricsServer = "metrics.masu.rs";

      # Disable passwords, only use SSH key
      passwordHash = null;
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Nextcloud backup config
      backupS3 = {
        endpoint = "s3.us-west-002.backblazeb2.com";
        bucket = "noahmasur-backup";
        accessKeyId = "0026b0e73b2e2c80000000004";
      };

      # Grant access to Jellyfin directories from Nextcloud
      users.users.nextcloud.extraGroups = [ "jellyfin" ];

      # Wireguard config for Transmission
      networking.wireguard.interfaces.wg0 = {

        # The local IPs for this machine within the Wireguard network
        # Any inbound traffic bound for these IPs should be kept on localhost
        ips = [ "10.66.13.200/32" "fc00:bbbb:bbbb:bb01::3:dc7/128" ];

        peers = [{

          # Identity of Wireguard target peer (VPN)
          publicKey = "bOOP5lIjqCdDx5t+mP/kEcSbHS4cZqE0rMlBI178lyY=";

          # The public internet address of the target peer
          endpoint = "86.106.143.132:51820";

          # Which outgoing IP ranges should be sent through Wireguard
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];

          # Send heartbeat signal within the network
          persistentKeepalive = 25;

        }];

      };

      # VPN port forwarding
      services.transmission.settings.peer-port = 57599;

      # Grant access to Transmission directories from Jellyfin
      users.users.jellyfin.extraGroups = [ "transmission" ];
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nixos
    ../../modules/hardware/server.nix
    ../../modules/services/sshd.nix
    ../../modules/services/calibre.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/nextcloud.nix
    ../../modules/services/transmission.nix
    ../../modules/services/prometheus.nix
    ../../modules/gaming/minecraft-server.nix
  ];
}
