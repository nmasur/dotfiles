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
          default = "http_status:404";
          ingress = { "*.masu.rs" = "ssh://localhost:22"; };
        };
      };
    };

    environment.etc = {
      "ssh/ca.pub".text = ''
        ${config.cloudflareTunnel.ca}
      '';

      # Must match the username of the email address in Cloudflare Access
      "ssh/authorized_principals".text = ''
        ${config.user}
      '';
    };

    services.openssh.extraConfig = ''
      PubkeyAuthentication yes
      TrustedUserCAKeys /etc/ssh/ca.pub
      Match User '${config.user}'
        AuthorizedPrincipalsFile /etc/ssh/authorized_principals
        # if there is no existing AuthenticationMethods
        AuthenticationMethods publickey
    '';
    services.openssh.settings.Macs =
      [ "hmac-sha2-512" ]; # Fix for failure to find matching mac

    # Create credentials file for Cloudflare
    secrets.cloudflared = {
      source = config.cloudflareTunnel.credentialsFile;
      dest = "${config.secretsDirectory}/cloudflared";
      owner = "cloudflared";
      group = "cloudflared";
      permissions = "0440";
    };
    systemd.services.cloudflared-secret = {
      requiredBy =
        [ "cloudflared-tunnel-${config.cloudflareTunnel.id}.service" ];
      before = [ "cloudflared-tunnel-${config.cloudflareTunnel.id}.service" ];
    };

  };

}
