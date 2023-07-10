# The Hydra
# System configuration for WSL

{ self, ... }:

self.inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    self.inputs.wsl.nixosModules.wsl
    self.inputs.home-manager.nixosModules.home-manager
    self.nixosModules.globals
    self.nixosModules.common
    self.nixosModules.nixos
    self.nixosModules.wsl
    {
      networking.hostName = "hydra";
      identityFile = "/home/${globals.user}/.ssh/id_ed25519";
      gui.enable = false;
      theme = {
        colors = (import ../../colorscheme/gruvbox).dark;
        dark = true;
      };
      passwordHash = inputs.nixpkgs.lib.fileContents ../../password.sha512;
      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = globals.user;
        startMenuLaunchers = true;
        nativeSystemd = true;
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
