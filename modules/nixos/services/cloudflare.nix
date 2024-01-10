# This module is necessary for hosts that are serving through Cloudflare.

# Cloudflare is a CDN service that is used to serve the domain names and
# caching for my websites and services. Since Cloudflare acts as our proxy, we
# must allow access over the Internet from Cloudflare's IP ranges.

# We also want to validate our HTTPS certificates from Caddy. We'll use Caddy's
# DNS validation plugin to connect to Cloudflare and automatically create
# validation DNS records for our generated certificates.

{ config, pkgs, lib, ... }:

let

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

in {

  options.cloudflare.enable = lib.mkEnableOption "Use Cloudflare.";

  config = lib.mkIf config.cloudflare.enable {

    # Forces Caddy to error if coming from a non-Cloudflare IP
    caddy.cidrAllowlist = cloudflareIpRanges;

    # Tell Caddy to use Cloudflare DNS for ACME challenge validation
    services.caddy.package = pkgs.caddy-cloudflare; # Patched overlay
    caddy.tlsPolicies = [{
      issuers = [{
        module = "acme";
        challenges = {
          dns = {
            provider = {
              name = "cloudflare";
              api_token = "{env.CF_API_TOKEN}";
            };
            resolvers = [ "1.1.1.1" ];
          };
        };
      }];
    }];
    # Allow Caddy to read Cloudflare API key for DNS validation
    systemd.services.caddy.serviceConfig.EnvironmentFile =
      config.secrets.cloudflareApi.dest;

    # API key must have access to modify Cloudflare DNS records
    secrets.cloudflareApi = {
      source = ../../../private/cloudflare-api.age;
      dest = "${config.secretsDirectory}/cloudflare-api";
      owner = "caddy";
      group = "caddy";
    };

    # Allows Nextcloud to trust Cloudflare IPs
    services.nextcloud.extraOptions.trusted_proxies = cloudflareIpRanges;

  };
}
