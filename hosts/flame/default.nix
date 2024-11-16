# The Flame
# System configuration for an Oracle free server

# See [readme](../README.md) to explain how this file works.

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/
# These days, probably use nixos-anywhere instead.

{
  inputs,
  globals,
  overlays,
  ...
}:

inputs.nixpkgs.lib.nixosSystem rec {
  system = "aarch64-linux";
  specialArgs = {
    pkgs-stable = import inputs.nixpkgs-stable { inherit system; };
    pkgs-caddy = import inputs.nixpkgs-caddy { inherit system; };
  };
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

      # Not sure what's necessary but too afraid to remove anything
      imports = [ (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix") ];
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "usbhid"
      ];

      # File systems must be declared in order to boot

      # This is the root filesystem containing NixOS
      # I forgot to set a clean label for it
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/e1b6bd50-306d-429a-9f45-78f57bc597c3";
        fsType = "ext4";
      };

      # This is the boot filesystem for systemd-boot
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D5CA-237A";
        fsType = "vfat";
      };

      # Theming

      # Server doesn't require GUI
      gui.enable = false;

      # Still require colors for programs like Neovim, K9S
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
      };

      # Programs and services
      atuin.enable = true;
      cloudflare.enable = true; # Proxy traffic with Cloudflare
      dotfiles.enable = true; # Clone dotfiles
      neovim.enable = true;
      giteaRunner.enable = true;
      services.caddy.enable = true;
      services.grafana.enable = true;
      services.thelounge.enable = true;
      services.openssh.enable = true;
      services.victoriametrics.enable = true;
      services.influxdb2.enable = true;
      services.gitea.enable = true;
      services.vaultwarden.enable = true;
      services.minecraft-server.enable = true; # Setup Minecraft server
      services.n8n.enable = true;
      services.ntfy-sh.enable = true;
      services.postgresql.enable = true;
      services.uptime-kuma.enable = true;
      system.autoUpgrade.enable = true;

      # Allows private remote access over the internet
      cloudflareTunnel = {
        enable = true;
        id = "bd250ee1-ed2e-42d2-b627-039f1eb5a4d2";
        credentialsFile = ../../private/cloudflared-flame.age;
        ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK/6oyVqjFGX3Uvrc3VS8J9sphxzAnRzKC85xgkHfYgR3TK6qBGXzHrknEj21xeZrr3G2y1UsGzphWJd9ZfIcdA= open-ssh-ca@cloudflareaccess.org";
      };

      # Nextcloud backup config
      backup.s3 = {
        endpoint = "s3.us-west-002.backblazeb2.com";
        bucket = "noahmasur-backup";
        accessKeyId = "0026b0e73b2e2c80000000005";
      };

      # Disable passwords, only use SSH key
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s personal"
      ];

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
    }
  ];
}
