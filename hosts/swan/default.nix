# The Swan
# System configuration for my home NAS server

{ inputs, globals, overlays, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    disko.nixosModules.disko
    {
      server = true;
      networking.hostName = "swan";

      # head -c 8 /etc/machine-id
      networking.hostId = "600279f4"; # Random ID required for ZFS

      zfs.enable = true;
      disko = {
        enableConfig = true;
        devices = (import ../../disks/root.nix { disk = "/dev/nvme0n1"; });
        # // (import ../../disks/zfs.nix {
        #   pool = "tank";
        #   disks = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
        # });
      };
      boot.zfs.extraPools = [ "tank" ];

      gui.enable = false;
      theme = { colors = (import ../../colorscheme/gruvbox).dark; };
      nixpkgs.overlays = overlays;
      neovim.enable = true;
      caddy.enable = true;
      streamServer = "stream.masu.rs";
      nextcloudServer = "cloud.masu.rs";
      bookServer = "books.masu.rs";
      arrServer = "download.masu.rs";
      samba.enable = true;

      backup.s3 = {
        endpoint = "s3.us-west-002.backblazeb2.com";
        bucket = "noahmasur-backup";
        accessKeyId = "0026b0e73b2e2c80000000005";
      };

      # Disable passwords, only use SSH key
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Clone dotfiles
      dotfiles.enable = true;

      # services.nfs.server.enable = true;

    }
  ];
}
