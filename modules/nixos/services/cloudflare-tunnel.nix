# Cloudflare Tunnel is a service for accessing the network even behind a
# firewall, through outbound-only requests. It works by installing an agent on
# our machines that exposes services through Cloudflare Access (Zero Trust),
# similar to something like Tailscale.

# In this case, we're using Cloudflare Tunnel to enable SSH access over a web
# browser even when outside of my network. This is probably not the safest
# choice but I feel comfortable enough with it anyway.

{ config, lib, ... }:

# First time setup:

# nix-shell -p cloudflared
# cloudflared tunnel login
# cloudflared tunnel create <host>
# nix run github:nmasur/dotfiles#encrypt-secret > private/cloudflared-<host>.age
# Paste ~/.cloudflared/<id>.json
# Set tunnel.id = "<id>"
# Remove ~/.cloudflared/

# For SSH access:
# Cloudflare Zero Trust -> Access -> Applications -> Create Application
# Service Auth -> SSH -> Select Application -> Generate Certificate
# Set ca = "<public key>"

{

  options.cloudflareTunnel = {
    enable = lib.mkEnableOption "Use Cloudflare Tunnel";
    id = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare tunnel ID";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
      description = "Cloudflare tunnel credentials file (age-encrypted)";
    };
    ca = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare tunnel CA public key";
    };
  };

  config = lib.mkIf config.cloudflareTunnel.enable {

    services.cloudflared = {
      enable = true;
      tunnels = {
        "${config.cloudflareTunnel.id}" = {
          credentialsFile = config.secrets.cloudflared.dest;
          # Catch-all if no match (should never happen anyway)
          default = "http_status:404";
          # Match from ingress of any valid server name to SSH access
          ingress = {
            "*.masu.rs" = "ssh://localhost:22";
          };
        };
      };
    };

    # Grant Cloudflare access to SSH into this server
    environment.etc = {
      "ssh/ca.pub".text = ''
        ${config.cloudflareTunnel.ca}
      '';

      # Must match the username portion of the email address in Cloudflare
      # Access
      "ssh/authorized_principals".text = ''
        ${config.user}
      '';
    };

    # Adjust SSH config to allow access from Cloudflare's certificate
    services.openssh.extraConfig = ''
      PubkeyAuthentication yes
      TrustedUserCAKeys /etc/ssh/ca.pub
      Match User '${config.user}'
        AuthorizedPrincipalsFile /etc/ssh/authorized_principals
        # if there is no existing AuthenticationMethods
        AuthenticationMethods publickey
    '';
    services.openssh.settings.Macs = [ "hmac-sha2-512" ]; # Fix for failure to find matching mac

    # Create credentials file for Cloudflare
    secrets.cloudflared = {
      source = config.cloudflareTunnel.credentialsFile;
      dest = "${config.secretsDirectory}/cloudflared";
      owner = "cloudflared";
      group = "cloudflared";
      permissions = "0440";
    };
    systemd.services.cloudflared-secret = {
      requiredBy = [ "cloudflared-tunnel-${config.cloudflareTunnel.id}.service" ];
      before = [ "cloudflared-tunnel-${config.cloudflareTunnel.id}.service" ];
    };
  };
}
