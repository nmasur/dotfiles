{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.actualtap;

  actualtapConfigType = lib.types.submodule {
    options = {
      port = lib.mkOption {
        type = lib.types.port;
        description = "Port to use for the actualtap instance localhost";
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "Path prefix for this actualtap instance on the reverse proxy";
      };
      budgetIdFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the age encrypted file containing the budget ID";
      };
      apiKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the age encrypted file containing the API key";
      };
    };
  };

in

{
  options.nmasur.presets.services.actualtap = {
    enable = lib.mkEnableOption "ActualTap instances";
    instances = lib.mkOption {
      type = lib.types.attrsOf actualtapConfigType;
      default = { };
      description = "Attribute set of ActualTap instances.";
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.actualtap = {
      isSystemUser = true;
      group = "shared";
      uid = 981;
    };

    systemd.services = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "actualtap-${name}" {
        enable = true;
        description = "ActualTap - ${name}";
        after = [
          "network.target"
          "actual.service"
        ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          PORT = builtins.toString instance.port;
          ACTUAL_URL = "http://127.0.0.1:${builtins.toString config.nmasur.presets.services.actualbudget.port}";
        };

        serviceConfig = {
          User = config.users.users.actualtap.name;
          Group = config.users.users.actualtap.group;
          EnvironmentFile = [
            config.secrets."actualbudget-password".dest
            config.secrets."actualtap-${name}-budget-id".dest
            config.secrets."actualtap-${name}-api-key".dest
          ];
          ExecStart = lib.getExe pkgs.nmasur.actualtap;
          Restart = "on-failure";
          WorkingDirectory = "/var/lib/actualtap-${name}";
          StateDirectory = "actualtap-${name}";
        };
      }
    ) cfg.instances;

    secrets = lib.mkMerge (
      lib.mapAttrsToList (name: instance: {
        "actualtap-${name}-budget-id" = {
          source = instance.budgetIdFile;
          dest = "${config.secretsDirectory}/actualtap-${name}-budget-id";
          owner = config.users.users.actualtap.name;
          group = config.users.users.actualtap.group;
        };
        "actualtap-${name}-api-key" = {
          source = instance.apiKeyFile;
          dest = "${config.secretsDirectory}/actualtap-${name}-api-key";
          owner = config.users.users.actualtap.name;
          group = config.users.users.actualtap.group;
        };
      }) cfg.instances
    );

    nmasur.presets.services.caddy.routes = lib.mapAttrsToList (name: instance: {
      group = "actual";
      match = [
        {
          host = [ hostnames.budget ];
          path = [ "${instance.path}*" ];
        }
      ];
      handle = [
        {
          handler = "rewrite";
          strip_path_prefix = instance.path;
        }
        {
          handler = "reverse_proxy";
          upstreams = [ { dial = "localhost:${builtins.toString instance.port}"; } ];
        }
      ];
    }) cfg.instances;
  };
}
