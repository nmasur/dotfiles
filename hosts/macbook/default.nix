{ nixpkgs, darwin, home-manager, nur, globals, ... }:

# System configuration for my MacBook
darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    globals
    home-manager.darwinModules.home-manager
    {
      user = "Noah.Masur";
      gui.enable = true;
      gui.colorscheme = (import ../modules/colorscheme/gruvbox);
      nixpkgs.overlays = [ nur.overlay ];
    }
    ../common.nix
    ../../modules/darwin
    ../../modules/applications/alacritty.nix
    ../../modules/applications/discord.nix
  ];
}
