{ config, ... }: {

  home-manager.users.${config.user} = {

    home.sessionVariables = {
      NOTES_PATH = "/home/${config.user}/dev/personal/notes";
    };

  };

}
