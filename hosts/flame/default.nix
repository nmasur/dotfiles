# The Flame
# System configuration for an Oracle free server

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/

{ inputs, globals, overlays, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { };
  modules = [
    globals
    inputs.home-manager.nixosModules.home-manager
    ../../modules/common
    ../../modules/nixos
    {
      nixpkgs.overlays = overlays;

      # Hardware
      server = true;
      networking.hostName = "flame";

      imports = [ (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix") ];
      boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/e1b6bd50-306d-429a-9f45-78f57bc597c3";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D5CA-237A";
        fsType = "vfat";
      };

      # Theming
      gui.enable = false;
      theme = { colors = (import ../../colorscheme/gruvbox).dark; };

      # Disable passwords, only use SSH key
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Programs and services
      cloudflare.enable = true; # Proxy traffic with Cloudflare
      dotfiles.enable = true; # Clone dotfiles
      neovim.enable = true;

      services.caddy.enable = true;
      services.grafana.enable = true;
      services.prometheus.enable = true;
      services.gitea.enable = true;
      services.vaultwarden.enable = true;
      services.minecraft-server.enable = true; # Setup Minecraft server

      cloudflareTunnel = {
        enable = true;
        id = "bd250ee1-ed2e-42d2-b627-039f1eb5a4d2";
        credentialsFile = ../../private/cloudflared-flame.age;
        ca =
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK/6oyVqjFGX3Uvrc3VS8J9sphxzAnRzKC85xgkHfYgR3TK6qBGXzHrknEj21xeZrr3G2y1UsGzphWJd9ZfIcdA= open-ssh-ca@cloudflareaccess.org";
      };

      # Nextcloud backup config
      backup.s3 = {
        endpoint = "s3.us-west-002.backblazeb2.com";
        bucket = "noahmasur-backup";
        accessKeyId = "0026b0e73b2e2c80000000005";
      };

      # # Grant access to Jellyfin directories from Nextcloud
      # users.users.nextcloud.extraGroups = [ "jellyfin" ];

      # # Wireguard config for Transmission
      # wireguard.enable = true;
      # networking.wireguard.interfaces.wg0 = {
      #
      #   # The local IPs for this machine within the Wireguard network
      #   # Any inbound traffic bound for these IPs should be kept on localhost
      #   ips = [ "10.66.13.200/32" "fc00:bbbb:bbbb:bb01::3:dc7/128" ];
      #
      #   peers = [{
      #
      #     # Identity of Wireguard target peer (VPN)
      #     publicKey = "bOOP5lIjqCdDx5t+mP/kEcSbHS4cZqE0rMlBI178lyY=";
      #
      #     # The public internet address of the target peer
      #     endpoint = "86.106.143.132:51820";
      #
      #     # Which outgoing IP ranges should be sent through Wireguard
      #     allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      #
      #     # Send heartbeat signal within the network
      #     persistentKeepalive = 25;
      #
      #   }];
      #
      # };

      # # VPN port forwarding
      # services.transmission.settings.peer-port = 57599;

      # # Grant access to Transmission directories from Jellyfin
      # users.users.jellyfin.extraGroups = [ "transmission" ];

    }
  ];
}
