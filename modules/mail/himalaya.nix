{ config, pkgs, lib, ... }: {

  options = {
    mailServer = lib.mkOption {
      type = lib.types.str;
      description = "Server name for the email address.";
    };
  };

  config = {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [ age ];

      programs.himalaya = { enable = true; };

      accounts.email = {
        maildirBasePath = "/home/${config.user}/mail";
        accounts = {
          main = let
            address = "${config.user}@${config.mailServer}";
            serverHostname = "mail.${config.mailServer}";
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
              host = serverHostname;
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
              enable = false;
              create = "maildir";
              expunge = "none";
              remove = "none";
              patterns = [ "*" ];
            };
            mu.enable = false;
            notmuch.enable = false;
            passwordCommand =
              "${pkgs.age}/bin/age --decrypt --identity /home/${config.user}/.ssh/id_ed25519 ${
                builtins.toString ./mailpass.age
              }";
            smtp = {
              host = serverHostname;
              port = 587;
              tls.enable = true;
            };
          };
        };
      };

      programs.fish.shellAbbrs = { hi = "himalaya"; };

    };

  };
}
