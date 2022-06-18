{ nixpkgs, darwin, home-manager, nur, globals, ... }:

# System configuration for my MacBook
darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    home-manager.darwinModules.home-manager
    {
      user = "Noah.Masur";
      fullName = globals.fullName;
      gitEmail = globals.gitEmail;
      mailServer = globals.mailServer;
      dotfilesRepo = globals.dotfilesRepo;
      dotfilesPath = "/Users/Noah.Masur/dev/dotfiles";
      gui = {
          enable = true;
          colorscheme = globals.gui.colorscheme;
      };
      nixpkgs.overlays = [ nur.overlay ];
    }
    ../common.nix
    ../../modules/darwin
    ../../modules/applications/alacritty.nix
    ../../modules/applications/discord.nix
    ../../modules/applications/obsidian.nix
  ];
}
