{ self, system, ... }:

self.inputs.nixos-generators.nixosGenerate {
  inherit system;
  format = "amazon";
  modules = [
    self.inputs.home-manager.nixosModules.home-manager
    self.nixosModules.globals
    self.nixosModules.common
    self.nixosModules.nixos
    {
      networking.hostName = "sheep";
      gui.enable = false;
      theme.colors = (import ../../colorscheme/gruvbox).dark;
      passwordHash = null;
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";
      # AWS settings require this
      permitRootLogin = "prohibit-password";
    }
  ] ++ [
    # Required to fix diskSize errors during build
    ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
  ];
}
