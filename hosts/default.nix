# Return a list of all hosts

{
  darwinConfigurations = import ./nix-darwin;
  nixosConfigurations = import ./nixos;
}
