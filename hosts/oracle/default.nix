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

      # Disable passwords, only use SSH key
      passwordHash = null;
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";

      # Grant access to Jellyfin directories from nextcloud
      users.users.nextcloud.extraGroups = [ "jellyfin" ];
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nixos
    ../../modules/hardware/server.nix
    ../../modules/services/sshd.nix
    ../../modules/services/calibre.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/nextcloud.nix
  ];
}
