{ pkgs, ... }:
{

  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "netdata-cloud" ''
      if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
      fi
      mkdir --parents --mode 0750 /var/lib/netdata/cloud.d
      printf "\nEnter the claim token for netdata cloud...\n\n"
      read -p "Token: " token
      echo "''${token}" > /var/lib/netdata/cloud.d/token
      chown -R netdata:netdata /var/lib/netdata
      ${pkgs.netdata}/bin/netdata-claim.sh -id=$(uuidgen)
      printf "\n\nNow restart netdata service.\n\n"
    ''
  );
}
