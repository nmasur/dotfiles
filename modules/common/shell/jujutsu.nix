{ config, ... }: {

  config = {

    home-manager.users.${config.user}.programs.jujutsu = {
      enable = true;
      enableFishIntegration = false; # Temp: not working

      # https://github.com/martinvonz/jj/blob/main/docs/config.md
      settings = {
        user = {
          name = config.home-manager.users.${config.user}.programs.git.userName;
          email =
            config.home-manager.users.${config.user}.programs.git.userEmail;
        };
      };
    };

  };

}
