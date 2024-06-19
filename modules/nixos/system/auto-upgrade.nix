{
  config,
  pkgs,
  lib,
  ...
}:
{

  # This setting only applies to NixOS, different on Darwin
  nix.gc.dates = "09:03"; # Run every morning (but before upgrade)

  # Update the system daily by pointing it at the flake repository
  system.autoUpgrade = {
    enable = lib.mkDefault false; # Don't enable by default
    dates = "09:33";
    flake = "git+${config.dotfilesRepo}";
    randomizedDelaySec = "25min";
    operation = "switch";
    allowReboot = true;
    rebootWindow = {
      lower = "09:01";
      upper = "11:00";
    };
  };

  # Create an email notification service for failed jobs
  systemd.services."notify-email@" =
    let
      address = "system@${config.mail.server}";
    in
    {
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
  systemd.services.nixos-upgrade.onFailure = lib.mkIf config.systemd.services."notify-email@".enable [
    "notify-email@%i.service"
  ];
}
