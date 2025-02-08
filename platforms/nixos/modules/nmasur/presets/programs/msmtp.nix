{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.msmtp;
in

{

  options.nmasur.presets.programs.msmtp = {
    enable = lib.mkEnableOption "System outgoing mail";
    host = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for SMTP";
      default = config.mail.smtpHost;
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "system@${config.mail.server}";
      default = config.mail.smtpHost;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
      setSendmail = true;
      accounts = {
        # The system user for sending automatic notifications
        default = {
          auth = true;
          host = cfg.host;
          passwordeval = "${pkgs.age}/bin/age --decrypt --identity ${config.identityFile} ${pkgs.writeText "mailpass-system.age" (builtins.readFile ../../../private/mailpass-system.age)}";
          user = cfg.user;
          from_full_name = "${config.networking.hostName} System";
          port = 465;
          tls = true;
        };
      };
    };

  };
}
