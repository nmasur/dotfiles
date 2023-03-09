# The Looking Glass
# System configuration for my work Macbook

{ inputs, globals, overlays, ... }:

with inputs;

darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    ../../modules/common
    ../../modules/darwin
    (globals // {
      user = "Noah.Masur";
      gitName = "Noah-Masur_1701";
      gitEmail = "Noah.Masur@take2games.com";
    })
    home-manager.darwinModules.home-manager
    {
      networking.hostName = "noah-masur-mac";
      identityFile = "/Users/Noah.Masur/.ssh/id_ed25519";
      gui.enable = true;
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
        dark = true;
      };
      mail.user = globals.user;
      nixpkgs.overlays = [ firefox-darwin.overlay ] ++ overlays;
      # Set registry to flake packages, used for nix X commands
      nix.registry.nixpkgs.flake = nixpkgs;
      charm.enable = true;
      neovim.enable = true;
      mail.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = true;
      kitty.enable = true;
      discord.enable = true;
      firefox.enable = true;
      dotfiles.enable = true;
      nixlang.enable = true;
      terraform.enable = true;
      python.enable = true;
      lua.enable = true;
      kubernetes.enable = true;
      _1password.enable = true;
      slack.enable = true;
    }
  ];
}
