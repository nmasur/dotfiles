{ config, lib, pkgs, ... }: {

  imports = [
    ../modules/hardware
    ../modules/system
    ../modules/graphical
    ../modules/shell
    ../modules/gaming
    ../modules/applications
    ../modules/editor
    ../modules/mail/himalaya.nix
  ];

  config = {

    nix.extraOptions = "experimental-features = nix-command flakes";

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    environment.systemPackages = with pkgs; [ git vim wget curl ];

  };

}
