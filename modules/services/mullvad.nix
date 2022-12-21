{ config, pkgs, lib, ... }: {

  options.mullvad.enable = lib.mkEnableOption "Mullvad VPN.";

  config = lib.mkIf config.mullvad.enable {

    services.mullvad-vpn.enable = true;
    environment.systemPackages = [ pkgs.mullvad-vpn ];

  };

}
