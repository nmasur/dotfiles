{ config, pkgs, lib, ... }: {

  imports = [ ./doas.nix ./journald.nix ./user.nix ./timezone.nix ];

  config = lib.mkIf pkgs.stdenv.isLinux {

    # Pin a state version to prevent warnings
    system.stateVersion =
      config.home-manager.users.${config.user}.home.stateVersion;

    # This setting only applies to NixOS, different on Darwin
    nix.gc.dates = "weekly";

    systemd.timers.nix-gc.timerConfig = { WakeSystem = true; };
    systemd.services.nix-gc.postStop =
      lib.mkIf (!config.server) "systemctl suspend";

    # Update the system daily
    system.autoUpgrade = {
      enable = config.server; # Only auto upgrade servers
      dates = "03:33";
      flake = "git+${config.dotfilesRepo}";
      randomizedDelaySec = "45min";
      operation = "switch";
      allowReboot = config.server; # Reboot servers
      rebootWindow = {
        lower = "00:01";
        upper = "06:00";
      };
    };

    # Create an email notification service for failed jobs
    systemd.services."notify-email@" =
      let address = "system@${config.mail.server}";
      in {
        enable = config.mail.enable;
        environment.SERVICE_ID = "%i";
        script = ''
          TEMPFILE=$(mktemp)
          echo "From: ${address}" > $TEMPFILE
          echo "To: ${address}" >> $TEMPFILE
          echo "Subject: Failure in $SERVICE_ID" >> $TEMPFILE
          echo -e "\nGot an error with $SERVICE_ID\n\n" >> $TEMPFILE
          set +e
          systemctl status $SERVICE_ID >> $TEMPFILE
          set -e
          ${pkgs.msmtp}/bin/msmtp \
              --file=${config.homePath}/.config/msmtp/config \
              --account=system \
              ${address} < $TEMPFILE
        '';
      };

    # Send an email whenever auto upgrade fails
    systemd.services.nixos-upgrade.onFailure =
      lib.mkIf config.systemd.services."notify-email@".enable
      [ "notify-email@%i.service" ];

  };

}
