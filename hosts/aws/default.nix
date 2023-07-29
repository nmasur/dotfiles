{ inputs, system, globals, overlays, ... }:

inputs.nixos-generators.nixosGenerate {
  inherit system;
  format = "amazon";
  modules = [
    globals
    inputs.home-manager.nixosModules.home-manager
    {
      nixpkgs.overlays = overlays;
      networking.hostName = "sheep";
      gui.enable = false;
      theme.colors = (import ../../colorscheme/gruvbox).dark;
      passwordHash = null;
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";
      # AWS settings require this
      permitRootLogin = "prohibit-password";
    }
    ../../modules/common
    ../../modules/nixos
    ../../modules/nixos/services/sshd.nix
  ] ++ [
    # Required to fix diskSize errors during build
    ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
  ];
}
