{ inputs, globals, overlays, ... }:

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
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    {
      physical = true;
      networking.hostName = "desktop";
      nixpkgs.overlays = [ nur.overlay ] ++ overlays;
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
      wsl.enable = false;
      publicKey = null;

      neovim.enable = true;
      media.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      "1password".enable = true;
      discord.enable = true;
      nautilus.enable = true;
      obsidian.enable = true;
      mail.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = true;
      keybase.enable = true;
      # mullvad.enable = true;
      nixlang.enable = true;
      dotfiles.enable = true;

      gaming = {
        enable = true;
        steam.enable = true;
        legendary.enable = true;
        lutris.enable = true;
        leagueoflegends.enable = true;
      };

    }
  ];
}
