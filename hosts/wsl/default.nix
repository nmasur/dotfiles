{ inputs, globals, overlays, ... }:

with inputs;

# System configuration for WSL
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    ../../modules
    ../../nixos
    globals
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "wsl";
      nixpkgs.overlays = overlays;
      # Set registry to flake packages, used for nix X commands
      nix.registry.nixpkgs.flake = nixpkgs;
      identityFile = "/home/${globals.user}/.ssh/id_ed25519";
      gui.enable = false;
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
        dark = true;
      };
      passwordHash = nixpkgs.lib.fileContents ../../private/password.sha512;
      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = globals.user;
        startMenuLaunchers = true;
        wslConf.network.generateResolvConf = true; # Turn off if it breaks VPN
        interop.includePath =
          false; # Including Windows PATH will slow down Neovim command mode
      };

      neovim.enable = true;
      mail.enable = true;
      mail.aerc.enable = true;
      mail.himalaya.enable = true;
      dotfiles.enable = true;
      nixlang.enable = true;
      lua.enable = true;
    }
  ];
}
