{ nixpkgs, wsl, home-manager, globals, ... }:

# System configuration for WSL
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { };
  modules = [
    globals
    home-manager.nixosModules.home-manager
    wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "wsl";
      gui.enable = false;
      passwordHash =
        "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
      wsl = {
        enable = true;
        automountPath = "/mnt";
        defaultUser = globals.user;
        startMenuLaunchers = true;
      };
    }
    ../common.nix
    ../../modules/system
    ../../modules/programming/nix.nix
    ../../modules/programming/lua.nix
  ];
}
