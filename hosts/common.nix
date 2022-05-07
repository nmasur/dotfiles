{ config, lib, pkgs, ... }: {

  nix.extraOptions = "experimental-features = nix-command flakes";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  environment.systemPackages = with pkgs; [ git vim wget curl ];

}
