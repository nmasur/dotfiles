{ nixpkgs, home-manager, nur, globals, ... }:

# System configuration for my desktop
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    globals
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "desktop";
      gui.enable = true;
      gui.compositor.enable = true;
      nixpkgs.overlays = [ nur.overlay ];
      gaming.steam = true;
      gaming.leagueoflegends = true;
      gaming.legendary = true;
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/services/keybase.nix
    ../../modules/services/gnupg.nix
    ../../modules/services/mullvad.nix
  ];
}
