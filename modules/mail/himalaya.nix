{ config, ... }: {

  config = {

    home-manager.users.${config.user} = {

      programs.himalaya = { enable = true; };
      accounts.email.accounts.home.himalaya = {
        enable = true;
        backend = "imap";
        sender = "smtp";
        settings = {
          downloads-dir = config.userDirs.download;
          smtp-insecure = true;
        };
      };

      programs.fish.shellAbbrs = { hi = "himalaya"; };

    };

  };
}
