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
    ./jellyfin.nix
    ./keybase.nix
    ./mullvad.nix
    ./n8n.nix
    ./netdata.nix
    ./nextcloud.nix
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
