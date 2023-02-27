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
    (removeAttrs globals [ "mail.server" ])
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    disko.nixosModules.disko
    {
      server = true;
      zfs.enable = true;

      disko = {
        enableConfig = true;
        devices.disks = import ../../disks/root.nix { disk = "/dev/nvme0n1"; };
      };

      # head -c 8 /etc/machine-id
      networking.hostId = "600279f4"; # Random ID required for ZFS

      gui.enable = false;
      theme = { colors = (import ../../colorscheme/gruvbox).dark; };
      nixpkgs.overlays = overlays;
      wsl.enable = false;
      caddy.enable = true;

      networking.hostName = "swan";

      # Disable passwords, only use SSH key
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Clone dotfiles
      dotfiles.enable = true;

      neovim.enable = true;

      # boot.zfs.enabled = true;
      # boot.kernelPackages =
      # config.boot.zfs.package.latestCompatibleLinuxPackages;
      # boot.zfs.extraPools = [ "mypool" ];
      # services.zfs.autoScrub.enable = true;
      # services.zfs.autoScrub.interval = "daily";

      # services.nfs.server.enable = true;

    }
  ];
}
