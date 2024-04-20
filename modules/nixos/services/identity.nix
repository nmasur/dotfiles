{ config, ... }:
{

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
          if [ -f ${config.identityFile} ]; then
              echo "Identity file found."
              exit 0
          fi
          sleep 6
      done
    '';
  };
}
