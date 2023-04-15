# The Tempest
# System configuration for my desktop

{ inputs, globals, overlays, ... }:

with inputs;

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    globals
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    {
      physical = true;
      networking.hostName = "tempest";
      gui.enable = true;
      nixpkgs.overlays = [ nur.overlay ] ++ overlays;
      passwordHash = nixpkgs.lib.fileContents ../../password.sha512;

      # Must be prepared ahead
      identityFile = "/home/${globals.user}/.ssh/id_ed25519";

      # Theming
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
        dark = true;
      };
      wallpaper = "${wallpapers}/gruvbox/road.jpg";
      gtk.theme.name = nixpkgs.lib.mkDefault "Adwaita-dark";

      # Programs and services
      charm.enable = true;
      neovim.enable = true;
      media.enable = true;
      dotfiles.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      _1password.enable = true;
      discord.enable = true;
      nautilus.enable = true;
      obsidian.enable = true;
      mail.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = true;
      keybase.enable = true;
      mullvad.enable = false;
      nixlang.enable = true;
      yt-dlp.enable = true;
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
