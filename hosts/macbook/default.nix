{ nixpkgs, darwin, home-manager, nur, globals, ... }:

# System configuration for my MacBook
darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    (globals // { user = "Noah.Masur"; })
    home-manager.darwinModules.home-manager
    {
      gui.enable = true;
      gui.colorscheme = (import ../../modules/colorscheme/gruvbox);
      mailUser = globals.user;
      nixpkgs.overlays = [ nur.overlay ];
    }
    ../common.nix
    ../../modules/darwin
    ../../modules/applications/alacritty.nix
    ../../modules/applications/discord.nix
    ../../modules/programming/nix.nix
    ../../modules/programming/terraform.nix
    # ../../modules/programming/python.nix
    ../../modules/programming/lua.nix
    ../../modules/programming/kubernetes.nix
  ];
}
