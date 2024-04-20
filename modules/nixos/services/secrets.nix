# Secrets management method taken from here:
# https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20

# In my case, I pre-encrypt my secrets and commit them to git.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {

    secretsDirectory = lib.mkOption {
      type = lib.types.str;
      description = "Default path to place secrets.";
      default = "/var/private";
    };

    secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.path;
              description = "Path to encrypted secret.";
            };
            dest = lib.mkOption {
              type = lib.types.str;
              description = "Resulting path for decrypted secret.";
            };
            owner = lib.mkOption {
              default = "root";
              type = lib.types.str;
              description = "User to own the secret.";
            };
            group = lib.mkOption {
              default = "root";
              type = lib.types.str;
              description = "Group to own the secret.";
            };
            permissions = lib.mkOption {
              default = "0400";
              type = lib.types.str;
              description = "Permissions expressed as octal.";
            };
            prefix = lib.mkOption {
              default = "";
              type = lib.types.str;
              description = "Prefix for secret value (for environment files).";
            };
          };
        }
      );
      description = "Set of secrets to decrypt to disk.";
      default = { };
    };
  };

  config = lib.mkIf pkgs.stdenv.isLinux {

    # Create a default directory to place secrets

    systemd.tmpfiles.rules = [ "d ${config.secretsDirectory} 0755 root wheel" ];

    # Declare oneshot service to decrypt secret using SSH host key
    # - Requires that the secret is already encrypted for the host
    # - Encrypt secrets: nix run github:nmasur/dotfiles#encrypt-secret

    systemd.services = lib.mapAttrs' (name: attrs: {
      name = "${name}-secret";
      value = {

        description = "Decrypt secret for ${name}";
        wantedBy = [ "multi-user.target" ];
        bindsTo = [ "wait-for-identity.service" ];
        after = [ "wait-for-identity.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          echo "${attrs.prefix}$(
            ${pkgs.age}/bin/age --decrypt \
                --identity ${config.identityFile} ${attrs.source}
          )" > ${attrs.dest}

          chown '${attrs.owner}':'${attrs.group}' '${attrs.dest}'
          chmod '${attrs.permissions}' '${attrs.dest}'
        '';
      };
    }) config.secrets;

    # Example declaration
    # config.secrets.my-secret = {
    #   source = ../../private/my-secret.age;
    #   dest = "/var/lib/private/my-secret";
    #   owner = "my-app";
    #   group = "my-app";
    #   permissions = "0440";
    # };
  };
}
