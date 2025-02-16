{ config, lib, ... }:

let
  cfg = config.services.wait-for-identity;
in
{

  options.services.wait-for-identity = {
    enable = lib.mkEnableOption "Wait for identity file oneshot";
    identityFile = lib.mkOption {
      type = lib.types.path;
      default = config.identityFile;
    };
  };

  config = lib.mkIf cfg.enable {

    # Wait for secret to be placed on the machine
    systemd.services.wait-for-identity = {
      description = "Wait until identity file exists on the machine";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for i in $(seq 1 10); do
            if [ -f ${builtins.toString cfg.identityFile} ]; then
                echo "Identity file found."
                exit 0
            fi
            sleep 6
        done
      '';
    };

  };
}
