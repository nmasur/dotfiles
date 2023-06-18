{ config, lib, ... }:

# First time setup:

# nix-shell -p cloudflared
# cloudflared tunnel login
# cloudflared tunnel create <mytunnel>
# nix run github:nmasur/dotfiles#encrypt-secret > private/cloudflared.age
# Paste ~/.cloudflared/<id>.json
# Set tunnelId = "<id>"
# Remove ~/.cloudflared/

let tunnelId = "646754ac-2149-4a58-b51a-e1d0a1f3ade2";

in {

  options.cloudflareTunnel.enable = lib.mkEnableOption "Use Cloudflare Tunnel";

  config = lib.mkIf config.cloudflareTunnel.enable {

    services.cloudflared = {
      enable = true;
      tunnels = {
        "${tunnelId}" = {
          credentialsFile = config.secrets.cloudflared.dest;
          default = "http_status:404";
          ingress = { "*.masu.rs" = "ssh://localhost:22"; };
        };
      };
    };

    environment.etc = {
      "ssh/ca.pub".text = ''
        ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCHF/UMtJqPFrf6f6GRY0ZFnkCW7b6sYgUTjTtNfRj1RdmNic1NoJZql7y6BrqQinZvy7nsr1UFDNWoHn6ah3tg= open-ssh-ca@cloudflareaccess.org
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
      source = ../../../private/cloudflared.age;
      dest = "${config.secretsDirectory}/cloudflared";
      owner = "cloudflared";
      group = "cloudflared";
      permissions = "0440";
    };
    systemd.services.cloudflared-secret = {
      requiredBy = [ "cloudflared-tunnel-${tunnelId}.service" ];
      before = [ "cloudflared-tunnel-${tunnelId}.service" ];
    };

  };

}
