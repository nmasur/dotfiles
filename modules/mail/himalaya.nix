{ config, ... }: {

  config = {

    home-manager.users.${config.user} = {

      programs.himalaya = { enable = true; };
      accounts.email.accounts.home.himalaya = {
        enable = true;
        settings = {
          backend = "imap";
          sender = "smtp";
          downloads-dir = config.userDirs.download;
          smtp-insecure = true;
        };
      };

      programs.fish.shellAbbrs = { hi = "himalaya"; };

    };

  };
}
