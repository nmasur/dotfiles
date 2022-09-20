{ nixpkgs, system, nixos-generators, home-manager, globals, ... }:

nixos-generators.nixosGenerate {
  inherit system;
  format = "amazon";
  modules = [
    home-manager.nixosModules.home-manager
    {
      user = globals.user;
      fullName = globals.fullName;
      dotfilesRepo = globals.dotfilesRepo;
      gitName = globals.gitName;
      gitEmail = globals.gitEmail;
      networking.hostName = "sheep";
      gui.enable = false;
      colorscheme = (import ../modules/colorscheme/gruvbox);
      passwordHash =
        "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s";
      # AWS settings require this
      permitRootLogin = "prohibit-password";
    }
    ../hosts/common.nix
    ../modules/nixos
    ../modules/services/sshd.nix
  ] ++ [
    # Required to fix diskSize errors during build
    ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
  ];
}
