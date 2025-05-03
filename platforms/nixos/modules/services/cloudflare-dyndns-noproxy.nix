{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.cloudflare-dyndns-noproxy;
in

{

  options.services.cloudflare-dyndns-noproxy.enable = lib.mkEnableOption "Cloudflare dyndns client without proxying";

  config = lib.mkIf cfg.enable {

    # Run a second copy of dyn-dns for non-proxied domains
    # Adapted from: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/cloudflare-dyndns.nix
    systemd.services.cloudflare-dyndns-noproxy =
      lib.mkIf ((builtins.length config.nmasur.presets.services.cloudflare.noProxyDomains) > 0)
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
            CLOUDFLARE_DOMAINS = toString config.nmasur.presets.services.cloudflare.noProxyDomains;
          };

          serviceConfig = {
            Type = "simple";
            DynamicUser = true;
            StateDirectory = "cloudflare-dyndns-noproxy";
            Environment = [ "XDG_CACHE_HOME=%S/cloudflare-dyndns-noproxy/.cache" ];
            LoadCredential = [
              "apiToken:${config.services.cloudflare-dyndns.apiTokenFile}"
            ];
          };

          script =
            let
              args =
                [ "--cache-file /var/lib/cloudflare-dyndns-noproxy/ip.cache" ]
                ++ (if config.services.cloudflare-dyndns.ipv4 then [ "-4" ] else [ "-no-4" ])
                ++ (if config.services.cloudflare-dyndns.ipv6 then [ "-6" ] else [ "-no-6" ])
                ++ lib.optional config.services.cloudflare-dyndns.deleteMissing "--delete-missing";
            in
            ''
              export CLOUDFLARE_API_TOKEN_FILE=''${CREDENTIALS_DIRECTORY}/apiToken
              echo $CLOUDFLARE_API_TOKEN_FILE
              cat $CLOUDFLARE_API_TOKEN_FILE

              # Added 2025-03-10: `cfg.apiTokenFile` used to be passed as an
              # `EnvironmentFile` to the service, which required it to be of
              # the form "CLOUDFLARE_API_TOKEN=" rather than just the secret.
              # If we detect this legacy usage, error out.
              token=$(< "''${CLOUDFLARE_API_TOKEN_FILE}")
              if [[ $token == CLOUDFLARE_API_TOKEN* ]]; then
                echo "Error: your api token starts with 'CLOUDFLARE_API_TOKEN='. Remove that, and instead specify just the token." >&2
                exit 1
              fi

              exec ${lib.getExe pkgs.cloudflare-dyndns} ${toString args}
            '';
        };
  };
}
