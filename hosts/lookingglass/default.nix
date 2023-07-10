# The Looking Glass
# System configuration for my work Macbook

{ self, ... }:

self.inputs.darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    self.inputs.home-manager.darwinModules.home-manager
    self.nixosModules.common
    self.nixosModules.darwin
    ({ config, lib, ... }: {
      config = rec {
        user = lib.mkForce "Noah.Masur";
        gitName = lib.mkForce "Noah-Masur_1701";
        gitEmail = lib.mkForce "${user}@take2games.com";
        nixpkgs.overlays = [ self.inputs.firefox-darwin.overlay ];
        networking.hostName = "lookingglass";
        identityFile = "/Users/${user}/.ssh/id_ed25519";
        gui.enable = true;
        theme = {
          colors = (import ../../colorscheme/gruvbox-dark).dark;
          dark = true;
        };
        mail.user = globals.user;
        charm.enable = true;
        neovim.enable = true;
        mail.enable = true;
        mail.aerc.enable = true;
        mail.himalaya.enable = false;
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
      };
    })
  ];
}
