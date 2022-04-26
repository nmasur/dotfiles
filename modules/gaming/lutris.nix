{ config, pkgs, ... }:

{

  imports = [ ./common.nix ];

  config = { environment.systemPackages = with pkgs; [ lutris amdvlk wine ]; };

}
