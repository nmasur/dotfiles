{ config, pkgs, lib, ... }: {

  imports = [ ./himalaya.nix ./aerc.nix ];

  options = {
    mail.user = lib.mkOption {
      type = lib.types.str;
      description = "User name for the email address.";
      default = config.user;
    };
    mail.server = lib.mkOption {
      type = lib.types.str;
      description = "Server name for the email address.";
    };
  };

  config = lib.mkIf (config.mail.user != null && config.mail.server != null) {

    home-manager.users.${config.user} = {
      programs.mbsync = { enable = true; };
      services.mbsync = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        frequency = "*:0/5";
      };
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
              host = "imap.purelymail.com";
              port = 993;
              tls.enable = true;
            };
            imapnotify = {
              enable = false;
              boxes = [ ];
              onNotify = "";
              onNotifyPost = "";
            };
            maildir = { path = "main"; };
            mbsync = {
              enable = true;
              create = "maildir";
              expunge = "none";
              remove = "none";
              patterns = [ "*" ];
              extraConfig.channel = {
                CopyArrivalDate = "yes"; # Sync time of original message
              };
            };
            mu.enable = false;
            notmuch.enable = false;
            passwordCommand =
              "${pkgs.age}/bin/age --decrypt --identity ${config.identityFile} ${
                builtins.toString ../../private/mailpass.age
              }";
            smtp = {
              host = "smtp.purelymail.com";
              port = 465;
              tls.enable = true;
            };
          };
        };
      };

    };

  };
}
