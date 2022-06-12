{ nixpkgs, darwin, home-manager, nur, globals, ... }:

# System configuration for my MacBook
darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    globals
    home-manager.darwinModules.home-manager
    {
      networking.hostName = "desktop";
      gui.enable = true;
      gui.compositor.enable = true;
      nixpkgs.overlays = [ nur.overlay ];
    }
    ../common.nix
  ];
}
