# The Flame
# System configuration for an Oracle free server

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/

{ inputs, globals, overlays, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { };
  modules = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    (removeAttrs globals [ "mail.server" ])
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    {
      server = true;
      gui.enable = false;
      theme = { colors = (import ../../colorscheme/gruvbox).dark; };
      nixpkgs.overlays = overlays;
      wsl.enable = false;
      caddy.enable = true;

      # FQDNs for various services
      networking.hostName = "flame";
      bookServer = "books.masu.rs";
      streamServer = "stream.masu.rs";
      nextcloudServer = "cloud.masu.rs";
      transmissionServer = "download.masu.rs";
      metricsServer = "metrics.masu.rs";
      vaultwardenServer = "vault.masu.rs";
      giteaServer = "git.masu.rs";

      # Disable passwords, only use SSH key
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Nextcloud backup config
      backup.s3 = {
        endpoint = "s3.us-west-002.backblazeb2.com";
        bucket = "noahmasur-backup";
        accessKeyId = "0026b0e73b2e2c80000000005";
      };

      # Grant access to Jellyfin directories from Nextcloud
      users.users.nextcloud.extraGroups = [ "jellyfin" ];

      # Wireguard config for Transmission
      wireguard.enable = true;
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

      # Proxy traffic with Cloudflare
      cloudflare.enable = true;

      # Setup Minecraft server
      gaming.minecraft-server.enable = true;

      # Clone dotfiles
      dotfiles.enable = true;

      neovim.enable = true;

    }
  ];
}
