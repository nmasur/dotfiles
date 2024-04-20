# This is a tool for blocking IPs of anyone who attempts to scan all of my
# ports.

# Currently has some issues that don't make this viable.

{
  config,
  lib,
  pkgs,
  ...
}:

# Taken from:
# https://dataswamp.org/~solene/2022-09-29-iblock-implemented-in-nixos.html

# You will need to flush all rules when removing:
# https://serverfault.com/questions/200635/best-way-to-clear-all-iptables-rules

let

  portsToBlock = [
    25545
    25565
    25570
  ];
  portsString = builtins.concatStringsSep "," (builtins.map builtins.toString portsToBlock);

  # Block IPs for 20 days
  expire = 60 * 60 * 24 * 20;

  rules = table: [
    "INPUT -i eth0 -p tcp -m multiport --dports ${portsString} -m state --state NEW -m recent --set"
    "INPUT -i eth0 -p tcp -m multiport --dports ${portsString} -m state --state NEW -m recent --update --seconds 10 --hitcount 1 -j SET --add-set ${table} src"
    "INPUT -i eth0 -p tcp -m set --match-set ${table} src -j nixos-fw-refuse"
    "INPUT -i eth0 -p udp -m set --match-set ${table} src -j nixos-fw-refuse"
  ];

  create-rules = lib.concatStringsSep "\n" (
    builtins.map (rule: "iptables -C " + rule + " || iptables -A " + rule) (rules "blocked")
    ++ builtins.map (rule: "ip6tables -C " + rule + " || ip6tables -A " + rule) (rules "blocked6")
  );

  delete-rules = lib.concatStringsSep "\n" (
    builtins.map (rule: "iptables -C " + rule + " && iptables -D " + rule) (rules "blocked")
    ++ builtins.map (rule: "ip6tables -C " + rule + " && ip6tables -D " + rule) (rules "blocked6")
  );
in
{

  options.honeypot.enable = lib.mkEnableOption "Honeypot fail2ban system.";

  config.networking.firewall = lib.mkIf config.honeypot.enable {

    extraPackages = [ pkgs.ipset ];
    # allowedTCPPorts = portsToBlock;

    # Restore ban list when starting up
    extraCommands = ''
      if test -f /var/lib/ipset.conf
      then
          ipset restore -! < /var/lib/ipset.conf
      else
          ipset -exist create blocked hash:ip ${if expire > 0 then "timeout ${toString expire}" else ""}
          ipset -exist create blocked6 hash:ip family inet6 ${
            if expire > 0 then "timeout ${toString expire}" else ""
          }
      fi
      ${create-rules}
    '';

    # Save list when shutting down
    extraStopCommands = ''
      ipset -exist create blocked hash:ip ${if expire > 0 then "timeout ${toString expire}" else ""}
      ipset -exist create blocked6 hash:ip family inet6 ${
        if expire > 0 then "timeout ${toString expire}" else ""
      }
      ipset save > /var/lib/ipset.conf
      ${delete-rules}
    '';
  };
}
