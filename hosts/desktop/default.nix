{ nixpkgs, home-manager, nur, globals, ... }:

# System configuration for my desktop
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    globals
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "desktop";
      gui.enable = true;
      gui.compositor.enable = true;
      nixpkgs.overlays = [ nur.overlay ];
    }
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/hardware
    ../../modules/system
    ../../modules/graphical
    ../../modules/shell
    ../../modules/gaming
    ../../modules/mail/himalaya.nix
    ../../modules/services/keybase.nix
    ../../modules/services/gnupg.nix
    ../../modules/applications/firefox.nix
    ../../modules/applications/alacritty.nix
    ../../modules/applications/media.nix
    ../../modules/applications/1password.nix
    ../../modules/applications/discord.nix
    ../../modules/applications/calibre.nix
    ../../modules/editor/neovim
    ../../modules/editor/notes.nix
  ];
}
