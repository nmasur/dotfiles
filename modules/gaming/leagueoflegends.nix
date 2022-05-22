{ config, pkgs, lib, ... }: {

  options.gaming.leagueoflegends = lib.mkEnableOption "League of Legends";

  config = lib.mkIf config.gaming.leagueoflegends {

    # League of Legends anti-cheat
    boot.kernel.sysctl = { "abi.vsyscall32" = 0; };

    environment.systemPackages = with pkgs; [ openssl dconf ];

  };
}
