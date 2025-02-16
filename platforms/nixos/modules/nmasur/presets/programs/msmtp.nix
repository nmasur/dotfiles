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
      description = "Hostname for SMTP server";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for SMTP email";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username (email address) for SMTP";
      default = "system@${cfg.domain}";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Password file for SMTP";
      default = ../../../../../../private/mailpass-system.age;
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
          passwordeval = "${pkgs.age}/bin/age --decrypt --identity ${config.identityFile} ${pkgs.writeText "mailpass-system.age" (builtins.readFile cfg.passwordFile)}";
          user = cfg.user;
          from_full_name = "${config.networking.hostName} System";
          port = 465;
          tls = true;
        };
      };
    };

  };
}
