# This file imports all the other files in this directory for use as modules in
# my config.

{ ... }: {

  imports = [
    ./arr.nix
    ./backups.nix
    ./bind.nix
    ./caddy.nix
    ./calibre.nix
    ./cloudflare-tunnel.nix
    ./cloudflare.nix
    ./gitea-runner.nix
    ./gitea.nix
    ./gnupg.nix
    ./grafana.nix
    ./honeypot.nix
    ./influxdb2.nix
    ./jellyfin.nix
    ./keybase.nix
    ./mullvad.nix
    ./n8n.nix
    ./netdata.nix
    ./nextcloud.nix
    ./paperless.nix
    ./postgresql.nix
    ./prometheus.nix
    ./samba.nix
    ./secrets.nix
    ./sshd.nix
    ./transmission.nix
    ./vaultwarden.nix
    ./victoriametrics.nix
    ./wireguard.nix
  ];

}
