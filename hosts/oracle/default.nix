{ nixpkgs, home-manager, globals, ... }:

# System configuration for an Oracle free server
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { };
  modules = [
    (removeAttrs globals [ "mailServer" ])
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "oracle";
      bookServer = "books.masu.rs";
      streamServer = "stream.masu.rs";
      nextcloudServer = "cloud.masu.rs";
      gui.enable = false;
      colorscheme = (import ../../modules/colorscheme/gruvbox);
      passwordHash = null;
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";
      nextcloudS3 = {
        bucket = "noahmasur-nextcloud";
        hostname = "s3.us-west-002.backblazeb2.com";
        key = "0026b0e73b2e2c80000000003";
      };
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nixos
    ../../modules/hardware/server.nix
    ../../modules/services/oracle.nix
    ../../modules/services/sshd.nix
    ../../modules/services/calibre.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/nextcloud.nix
  ];
}
