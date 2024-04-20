{
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ./himalaya.nix
    ./aerc.nix
    ./system.nix
  ];

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
      programs.mbsync = {
        enable = true;
      };

      # Automatically check for mail and keep files synced locally
      services.mbsync = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        frequency = "*:0/5";
        postExec = "${pkgs.notmuch}/bin/notmuch new";
      };

      # Used to watch for new mail and trigger sync
      services.imapnotify.enable = pkgs.stdenv.isLinux;

      # Allows sending email from CLI/sendmail
      programs.msmtp.enable = true;

      # Better local mail search
      programs.notmuch = {
        enable = true;
        new.ignore = [
          ".mbsyncstate.lock"
          ".mbsyncstate.journal"
          ".mbsyncstate.new"
        ];
      };

      accounts.email = {

        # Where email files are stored
        maildirBasePath = "${config.homePath}/mail";

        accounts = {
          home =
            let
              address = "${config.mail.user}@${config.mail.server}";
            in
            {
              userName = address;
              realName = config.fullName;
              primary = true;
              inherit address;
              aliases = map (user: "${user}@${config.mail.server}") [
                "me"
                "hey"
                "admin"
              ];

              # Options for contact completion
              alot = { };

              imap = {
                host = config.mail.imapHost;
                port = 993;
                tls.enable = true;
              };

              # Watch for mail and run notifications or sync
              imapnotify = {
                enable = true;
                boxes = [ "Inbox" ];
                onNotify = "${pkgs.isync}/bin/mbsync -a";
                onNotifyPost =
                  lib.mkIf config.home-manager.users.${config.user}.services.dunst.enable
                    "${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
              };

              # Name of the directory in maildir for this account
              maildir = {
                path = "main";
              };

              # Bi-directional syncing options for local files
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

              # Enable indexing
              notmuch.enable = true;

              # Used to login and send and receive emails
              passwordCommand = "${pkgs.age}/bin/age --decrypt --identity ~/.ssh/id_ed25519 ${pkgs.writeText "mailpass.age" (builtins.readFile ../../../private/mailpass.age)}";

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
