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
      gaming.steam = true;
      gaming.leagueoflegends = true;
      gaming.legendary = true;
      gui = {
        enable = true;
        compositor.enable = true;
        colorscheme = (import ../../modules/colorscheme/gruvbox);
        wallpaper = "${wallpapers}/gruvbox/road.jpg";
        gtk.theme = { name = "Adwaita-dark"; };
      };
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
    ../../modules/services/keybase.nix
    ../../modules/services/gnupg.nix
    ../../modules/services/mullvad.nix
    ../../modules/programming/nix.nix
    ../../modules/programming/haskell.nix
  ];
}
