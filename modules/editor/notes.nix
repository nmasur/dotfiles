{ config, ... }: {

  home-manager.users.${config.user} = {

    home.sessionVariables = {
      NOTES_PATH = "${config.homePath}/dev/personal/notes";
    };

  };

}
