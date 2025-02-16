{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.nix-autoupgrade;
in

{

  options.nmasur.presets.services.nix-autoupgrade = {
    enable = lib.mkEnableOption "Nix auto upgrade";
    repo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Git URL of the flake repository to use for upgrades";
      default = "git@github.com:nmasur/dotfiles";
    };
  };

  config = lib.mkIf cfg.enable {

    # Update the system daily by pointing it at the flake repository
    system.autoUpgrade = {
      enable = true;
      dates = "09:33";
      flake = "git+${cfg.repo}";
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
          ${lib.getExe pkgs.msmtp} \
              --file=${config.home-manager.users.${username}.xdg.configDir}/msmtp/config \
              --account=system \
              ${address} < $TEMPFILE
        '';
      };

    # Send an email whenever auto upgrade fails
    systemd.services.nixos-upgrade.onFailure = lib.mkIf config.systemd.services."notify-email@".enable [
      "notify-email@%i.service"
    ];
  };
}
