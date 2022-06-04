{ pkgs, ... }: {

  services.mullvad-vpn.enable = true;
  environment.systemPackages = [ pkgs.mullvad-vpn ];

}
