{ nixpkgs, home-manager, nur, globals, wallpapers, ... }:

# System configuration for my desktop
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    globals
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "desktop";
      nixpkgs.overlays = [ nur.overlay ];
      # Set registry to flake packages, used for nix X commands
      nix.registry.nixpkgs.flake = nixpkgs;
      identityFile = "/home/${globals.user}/.ssh/id_ed25519";
      gaming.steam = true;
      gaming.legendary = true;
      gui = {
        enable = true;
        compositor.enable = true;
        wallpaper = "${wallpapers}/gruvbox/road.jpg";
        gtk.theme = { name = "Adwaita-dark"; };
      };
      colorscheme = (import ../../modules/colorscheme/gruvbox);
      passwordHash =
        "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
    }

    ./hardware-configuration.nix
    ../common.nix
    ../../modules/hardware
    ../../modules/nixos
    ../../modules/graphical
    ../../modules/gaming
    ../../modules/applications
    ../../modules/mail/himalaya.nix
    ../../modules/repositories/notes.nix
    ../../modules/services/keybase.nix
    ../../modules/services/gnupg.nix
    ../../modules/services/mullvad.nix
    ../../modules/programming/nix.nix
    ../../modules/programming/haskell.nix
  ];
}
