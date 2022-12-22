{ inputs, globals, ... }:

with inputs;

# System configuration for my desktop
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    ./hardware-configuration.nix
    ../../modules
    ../../nixos
    globals
    home-manager.nixosModules.home-manager
    {
      physical = true;
      networking.hostName = "desktop";
      nixpkgs.overlays = [ nur.overlay ];
      # Set registry to flake packages, used for nix X commands
      nix.registry.nixpkgs.flake = nixpkgs;
      identityFile = "/home/${globals.user}/.ssh/id_ed25519";
      gui.enable = true;
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
        dark = true;
      };
      wallpaper = "${wallpapers}/gruvbox/road.jpg";
      gtk.theme.name = nixpkgs.lib.mkDefault "Adwaita-dark";
      passwordHash = nixpkgs.lib.fileContents ../../private/password.sha512;

      media.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      "1password".enable = true;
      discord.enable = true;
      nautilus.enable = true;
      obsidian.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = true;
      gaming.enable = true;
      gaming.steam.enable = true;
      gaming.legendary.enable = true;
      keybase.enable = true;
      mullvad.enable = true;
      nixlang.enable = true;
      dotfiles.enable = true;
    }
  ];
}
