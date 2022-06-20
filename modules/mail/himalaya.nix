{ config, pkgs, lib, ... }: {

  options = {
    mailServer = lib.mkOption {
      type = lib.types.str;
      description = "Server name for the email address.";
    };
  };

  config = {

    home-manager.users.${config.user} = {

      programs.himalaya = { enable = true; };
      programs.mbsync = { enable = true; };
      services.mbsync = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        frequency = "*:0/5";
      };

      accounts.email = {
        maildirBasePath = "$HOME/mail";
        accounts = {
          home = let address = "${config.user}@${config.mailServer}";
          in {
            userName = address;
            realName = config.fullName;
            primary = true;
            inherit address;
            aliases = map (mailUser: "${mailUser}@${config.mailServer}") [
              "me"
              "hey"
              "admin"
            ];
            alot = { };
            flavor = "plain";
            folders = { };
            getmail = { };
            himalaya = {
              enable = true;
              settings = {
                downloads-dir = config.userDirs.download;
                smtp-insecure = true;
              };
            };
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
              "${pkgs.age}/bin/age --decrypt --identity ${config.homePath}/.ssh/id_ed25519 ${
                builtins.toString ./mailpass.age
              }";
            smtp = {
              host = "smtp.purelymail.com";
              port = 465;
              tls.enable = true;
            };
          };
        };
      };

      programs.fish.shellAbbrs = { hi = "himalaya"; };

    };

  };
}
