# murmur is a Mumble server for hosting voice chat

{
  config,
  lib,
  ...
}:
let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.murmur;
in

{

  options.nmasur.presets.services.murmur.enable =
    lib.mkEnableOption "murmur (mumble) voice chat service";

  config = lib.mkIf cfg.enable {

    services.murmur = {
      enable = true;
      users = 50; # Max concurrent users
      bonjour = false; # Auto-connect LAN
      registerUrl = "https://${hostnames.mumble}";
      registerName = "Mumble";
      environmentFile = null;
      sslKey = "${config.security.acme.certs."${hostnames.mumble}".directory}/key.pem";
      sslCert = "${config.security.acme.certs."${hostnames.mumble}".directory}/fullchain.pem";
      openFirewall = true;
    };

    # Configure Cloudflare DNS to point to this machine
    nmasur.presets.services.cloudflare.noProxyDomains = [ hostnames.mumble ];

    security.acme.certs."${hostnames.mumble}" = {
      dnsProvider = "cloudflare";
      credentialsFile = config.secrets.cloudflare-dns-api-prefixed.dest;
      group = config.services.murmur.group;
    };
  };
}
