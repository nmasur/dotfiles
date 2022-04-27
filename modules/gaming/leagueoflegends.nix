{ config, pkgs, lib, ... }:

with lib;
let cfg = config.modules.gaming.leagueoflegends;

in {

  options.modules.gaming.leagueoflegends = {
    enable = mkEnableOption "League of Legends";
  };

  config = mkIf cfg.enable {

    # League of Legends anti-cheat
    boot.kernel.sysctl = { "abi.vsyscall32" = 0; };

    environment.systemPackages = with pkgs; [ openssl dconf ];

  };
}
