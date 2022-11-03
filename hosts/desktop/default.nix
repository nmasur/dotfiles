{ inputs, globals, ... }:

with inputs;

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
      gui.enable = true;
      theme = {
        colors = (import ../../modules/colorscheme/gruvbox).dark;
        dark = true;
      };
      wallpaper = "${wallpapers}/gruvbox/road.jpg";
      gtk.theme.name = nixpkgs.lib.mkDefault "Adwaita-dark";
      passwordHash = nixpkgs.lib.fileContents ../../private/password.sha512;
    }

    ./hardware-configuration.nix
    ../common.nix
    ../../modules/hardware
    ../../modules/nixos
    ../../modules/graphical
    ../../modules/gaming/steam.nix
    ../../modules/gaming/legendary.nix
    ../../modules/applications/media.nix
    ../../modules/applications/firefox.nix
    ../../modules/applications/kitty.nix
    ../../modules/applications/discord.nix
    ../../modules/applications/nautilus.nix
    ../../modules/mail/default.nix
    ../../modules/repositories/notes.nix
    ../../modules/services/keybase.nix
    ../../modules/services/mullvad.nix
    ../../modules/programming/nix.nix
  ];
}
