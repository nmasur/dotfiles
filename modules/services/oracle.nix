{ pkgs, ... }: {

  # Needs to be run at boot for Oracle firewall
  systemd.services.openIpTables = {
    script = "${pkgs.iptables}/bin/iptables -I INPUT -j ACCEPT";
    wantedBy = [ "multi-user.target" ];
  };

}
