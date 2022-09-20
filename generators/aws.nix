{ nixpkgs, system, nixos-generators, home-manager, globals, ... }:

nixos-generators.nixoGenerate {
  inherit system;
  imports = [
    globals
    home-manager.nixosModules.home-manager
    {
      networking.hostName = "sheep";
      gui.enable = false;
      colorscheme = (import ../../modules/colorscheme/gruvbox);
      passwordHash =
        "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
    }
    ../hosts/common.nix
    ../modules/nixos
  ];
  format = "aws";
}
