{ config, pkgs, lib, ... }: {

  imports = [
    ./haskell.nix
    ./kubernetes.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./terraform.nix
  ];

}
