{ config, pkgs, ... }: {

  imports = [ ./common.nix ];

  config = {
    hardware.steam-hardware.enable = true;
    environment.systemPackages = with pkgs; [ steam ];
  };

}
