# This module is necessary for hosts that are serving through Cloudflare.

# Cloudflare is a CDN service that is used to serve the domain names and
# caching for my websites and services. Since Cloudflare acts as our proxy, we
# must allow access over the Internet from Cloudflare's IP ranges.

# We also want to validate our HTTPS certificates from Caddy. We'll use Caddy's
# DNS validation plugin to connect to Cloudflare and automatically create
# validation DNS records for our generated certificates.

{
  config,
  pkgs,
  lib,
  ...
}:

let

  cfg = config.nmasur.presets.services.cloudflare;

  cloudflareIpRanges = [

    # Cloudflare IPv4: https://www.cloudflare.com/ips-v4
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"

    # Cloudflare IPv6: https://www.cloudflare.com/ips-v6
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];
in
{

  options.nmasur.presets.services.cloudflare = {
    enable = lib.mkEnableOption "Cloudflare proxy configuration";

    noProxyDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Domains to use for dyndns without CDN proxying.";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {

    # Forces Caddy to error if coming from a non-Cloudflare IP
    nmasur.presets.services.caddy.cidrAllowlist = cloudflareIpRanges;

    # Tell Caddy to use Cloudflare DNS for ACME challenge validation
    services.caddy.package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@8cbec3f04d5b4a768c52941a5468c4b71436509e" ]; # v0.2.1
      hash = "sha256-2D7dnG50CwtCho+U+iHmSj2w14zllQXPjmTHr6lJZ/A=";
    };
    nmasur.presets.services.caddy.tlsPolicies = [
      {
        issuers = [
          {
            module = "acme";
            email = "acme@${config.nmasur.presets.programs.msmtp.domain}";
            account_key = "{env.ACME_ACCOUNT_KEY}";
            challenges = {
              dns = {
                provider = {
                  name = "cloudflare";
                  api_token = "{env.CLOUDFLARE_API_TOKEN}";
                };
                resolvers = [ "1.1.1.1" ];
              };
            };
          }
        ];
      }
    ];
    systemd.services.caddy.serviceConfig = {
      # Allow Caddy to read Cloudflare API key for DNS validation
      # Allow Caddy to use letsencrypt account key for TLS verification
      EnvironmentFile = [
        config.secrets.letsencrypt-key.dest
        config.secrets.cloudflare-api-prefixed.dest
      ];
    };

    # Private key is used for LetsEncrypt
    secrets.letsencrypt-key = {
      source = ./letsencrypt-key.age;
      dest = "${config.secretsDirectory}/letsencrypt-key";
      owner = "caddy";
      group = "caddy";
    };

    # API key must have access to modify Cloudflare DNS records
    secrets.cloudflare-api = {
      source = ./cloudflare-api.age;
      dest = "${config.secretsDirectory}/cloudflare-api";
      owner = "caddy";
      group = "caddy";
    };
    secrets.cloudflare-api-prefixed = {
      source = ./cloudflare-api.age;
      dest = "${config.secretsDirectory}/cloudflare-api-prefixed";
      owner = "caddy";
      group = "caddy";
      prefix = "CLOUDFLARE_API_TOKEN=";
    };
    # Wait for secret to exist
    systemd.services.caddy = {
      after = [
        "cloudflare-api-prefixed-secret.service"
        "letsencrypt-key-secret.service"
      ];
      requires = [
        "cloudflare-api-prefixed-secret.service"
        "letsencrypt-key-secret.service"
      ];
    };

    # Allows Nextcloud to trust Cloudflare IPs
    services.nextcloud.settings.trusted_proxies = cloudflareIpRanges;

    # Allows Transmission to trust Cloudflare IPs
    services.transmission.settings.rpc-whitelist = builtins.concatStringsSep "," (
      [ "127.0.0.1" ] ++ cloudflareIpRanges
    );

    # Using dyn-dns instead of ddclient because I can't find a way to choose
    # between proxied and non-proxied records for Cloudflare using just
    # ddclient.
    services.cloudflare-dyndns =
      lib.mkIf ((builtins.length config.services.cloudflare-dyndns.domains) > 0)
        {
          enable = true;
          proxied = true;
          deleteMissing = true;
          apiTokenFile = config.secrets.cloudflare-api.dest;
        };

    # Wait for secret to exist to start
    systemd.services.cloudflare-dyndns = lib.mkIf config.services.cloudflare-dyndns.enable {
      after = [ "cloudflare-api-secret.service" ];
      requires = [ "cloudflare-api-secret.service" ];
      script =
        let
          args = [
            "--cache-file /var/lib/cloudflare-dyndns/ip.cache"
          ]
          ++ (if config.services.cloudflare-dyndns.ipv4 then [ "-4" ] else [ "-no-4" ])
          ++ (if config.services.cloudflare-dyndns.ipv6 then [ "-6" ] else [ "-no-6" ])
          ++ lib.optional config.services.cloudflare-dyndns.deleteMissing "--delete-missing"
          ++ lib.optional config.services.cloudflare-dyndns.proxied "--proxied";
        in
        lib.mkForce ''
          export CLOUDFLARE_API_TOKEN=$(cat ''${CREDENTIALS_DIRECTORY}/apiToken)
          exec ${lib.getExe pkgs.cloudflare-dyndns} ${toString args}
        '';
    };

    # Enable the home-made service that we created for non-proxied records
    services.cloudflare-dyndns-noproxy.enable = true;

  };
}
