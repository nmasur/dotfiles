{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.cloudflare-dyndns-no-proxy;
in

{

  options.services.cloudflare-dyndns-no-proxy.enable = lib.mkEnableOption "Cloudflare dyndns client without proxying";

  config = lib.mkIf cfg.enable {

    # Run a second copy of dyn-dns for non-proxied domains
    # Adapted from: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/cloudflare-dyndns.nix
    systemd.services.cloudflare-dyndns-noproxy =
      lib.mkIf ((builtins.length config.cloudflare.noProxyDomains) > 0)
        {
          description = "CloudFlare Dynamic DNS Client (no proxy)";
          after = [
            "network.target"
            "cloudflare-api-secret.service"
          ];
          requires = [ "cloudflare-api-secret.service" ];
          wantedBy = [ "multi-user.target" ];
          startAt = "*:0/5";

          environment = {
            CLOUDFLARE_DOMAINS = toString config.cloudflare.noProxyDomains;
          };

          serviceConfig = {
            Type = "simple";
            DynamicUser = true;
            StateDirectory = "cloudflare-dyndns-noproxy";
            EnvironmentFile = config.services.cloudflare-dyndns.apiTokenFile;
            ExecStart =
              let
                args =
                  [ "--cache-file /var/lib/cloudflare-dyndns-noproxy/ip.cache" ]
                  ++ (if config.services.cloudflare-dyndns.ipv4 then [ "-4" ] else [ "-no-4" ])
                  ++ (if config.services.cloudflare-dyndns.ipv6 then [ "-6" ] else [ "-no-6" ])
                  ++ lib.optional config.services.cloudflare-dyndns.deleteMissing "--delete-missing";
              in
              "${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns ${toString args}";
          };
        };
  };
}
