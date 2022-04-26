{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./lutris.nix ];

  config = {

    # League of Legends anti-cheat
    boot.kernel.sysctl = { "abi.vsyscall32" = 0; };

    environment.systemPackages = with pkgs; [ openssl dconf ];

  };
}
