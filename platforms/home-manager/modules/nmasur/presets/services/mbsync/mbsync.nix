{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username fullName hostnames;
  cfg = config.nmasur.presets.services.mbsync;
in

{

  options.nmasur.presets.services.mbsync = {
    enable = lib.mkEnableOption "Mail service.";
    user = lib.mkOption {
      type = lib.types.str;
      description = "User name for the email address.";
      default = username;
    };
    server = lib.mkOption {
      type = lib.types.str;
      description = "Server name for the email address.";
      default = hostnames.mail;
    };
    imapHost = lib.mkOption {
      type = lib.types.str;
      description = "Server host for IMAP (reading mail).";
      default = hostnames.imap;
    };
    smtpHost = lib.mkOption {
      type = lib.types.str;
      description = "Server host for SMTP (sending mail).";
      default = hostnames.smtp;
    };
  };

  config = lib.mkIf cfg.enable {

    programs.mbsync = {
      enable = true;
    };

    # Automatically check for mail and keep files synced locally
    services.mbsync = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      frequency = "*:0/5";
      postExec = "${lib.getExe pkgs.notmuch} new";
    };

    # Used to watch for new mail and trigger sync
    services.imapnotify.enable = pkgs.stdenv.isLinux;

    # Allows sending email from CLI/sendmail
    programs.msmtp.enable = true;

    accounts.email = {

      # Where email files are stored
      maildirBasePath = "${config.home.homeDirectory}/mail";

      accounts = {
        home =
          let
            address = "${cfg.user}@${cfg.server}";
          in
          {
            userName = address;
            realName = fullName;
            primary = true;
            inherit address;
            aliases = map (user: "${user}@${cfg.server}") [
              "me"
              "hey"
              "admin"
            ];

            # Options for contact completion
            alot = { };

            imap = {
              host = cfg.imapHost;
              port = 993;
              tls.enable = true;
            };

            # Watch for mail and run notifications or sync
            imapnotify = {
              enable = true;
              boxes = [ "Inbox" ];
              onNotify = "${pkgs.isync}/bin/mbsync -a";
              onNotifyPost = lib.mkIf config.services.dunst.enable "${lib.getExe pkgs.libnotify} 'New mail arrived'";
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
            passwordCommand = "${lib.getExe pkgs.age} --decrypt --identity ~/.ssh/id_ed25519 ${pkgs.writeText "mailpass.age" (builtins.readFile ./mailpass.age)}";

            smtp = {
              host = cfg.smtpHost;
              port = 465;
              tls.enable = true;
            };
          };
      };
    };
  };
}
