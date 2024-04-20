{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf (config.mail.enable || config.server) {

    home-manager.users.${config.user} = {

      programs.msmtp.enable = true;

      # The system user for sending automatic notifications
      accounts.email.accounts.system =
        let
          address = "system@${config.mail.server}";
        in
        {
          userName = address;
          realName = "NixOS System";
          primary = !config.mail.enable; # Only primary if mail not enabled
          inherit address;
          passwordCommand = "${pkgs.age}/bin/age --decrypt --identity ${config.identityFile} ${pkgs.writeText "mailpass-system.age" (builtins.readFile ../../../private/mailpass-system.age)}";
          msmtp.enable = true;
          smtp = {
            host = config.mail.smtpHost;
            port = 465;
            tls.enable = true;
          };
        };
    };
  };
}
