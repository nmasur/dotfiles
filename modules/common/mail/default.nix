{ config, pkgs, lib, ... }: {

  imports = [ ./himalaya.nix ./aerc.nix ];

  options = {
    mail.enable = lib.mkEnableOption "Mail service.";
    mail.user = lib.mkOption {
      type = lib.types.str;
      description = "User name for the email address.";
      default = config.user;
    };
    mail.server = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Server name for the email address.";
    };
    mail.imapHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Server host for IMAP (reading mail).";
    };
    mail.smtpHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Server host for SMTP (sending mail).";
    };
  };

  config = lib.mkIf config.mail.enable {

    home-manager.users.${config.user} = {
      programs.mbsync = { enable = true; };
      services.imapnotify.enable = pkgs.stdenv.isLinux && config.physical;
      programs.notmuch.enable = true;
      accounts.email = {
        maildirBasePath = "${config.homePath}/mail";
        accounts = {
          home = let address = "${config.mail.user}@${config.mail.server}";
          in {
            userName = address;
            realName = config.fullName;
            primary = true;
            inherit address;
            aliases = map (user: "${user}@${config.mail.server}") [
              "me"
              "hey"
              "admin"
            ];
            alot = { };
            flavor = "plain";
            folders = { };
            getmail = { };
            imap = {
              host = config.mail.imapHost;
              port = 993;
              tls.enable = true;
            };
            imapnotify = {
              enable = true;
              boxes = [ "Inbox" ];
              onNotify = "${pkgs.isync}/bin/mbsync -a";
              onNotifyPost =
                "${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
            };
            maildir = { path = "main"; };
            mbsync = {
              enable = true;
              create = "both";
              expunge = "both";
              remove = "both";
              patterns = [ "*" ];
              extraConfig.channel = {
                CopyArrivalDate = "yes"; # Sync time of original message
              };
            };
            mu.enable = false;
            notmuch.enable = true;
            passwordCommand =
              "${pkgs.age}/bin/age --decrypt --identity ${config.identityFile} ${
                builtins.toString ../../../private/mailpass.age
              }";
            smtp = {
              host = config.mail.smtpHost;
              port = 465;
              tls.enable = true;
            };
          };
        };
      };

    };

  };
}
