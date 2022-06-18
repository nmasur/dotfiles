{ nixpkgs, darwin, home-manager, nur, globals, ... }:

# System configuration for my MacBook
darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    globals // { user = "Noah.Masur" }
    home-manager.darwinModules.home-manager
    {
      gui.enable = true;
      nixpkgs.overlays = [ nur.overlay ];
    }
    ../common.nix
    ../../modules/darwin
    ../../modules/applications/1password.nix
    ../../modules/applications/alacritty.nix
    ../../modules/applications/discord.nix
    ../../modules/applications/firefox.nix
    ../../modules/applications/obsidian.nix
  ];
}
