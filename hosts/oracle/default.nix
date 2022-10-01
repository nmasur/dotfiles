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
      gui.enable = false;
      colorscheme = (import ../../modules/colorscheme/gruvbox);
      passwordHash =
        "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nixos
    ../../modules/hardware/server.nix
    ../../modules/services/sshd.nix
    ../../modules/services/calibre.nix
  ];
}
