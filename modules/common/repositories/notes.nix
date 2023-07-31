{ config, ... }: {

  # This is just a placeholder as I expect to interact with my notes in a
  # certain location

  home-manager.users.${config.user} = {

    home.sessionVariables = {
      NOTES_PATH = "${config.homePath}/dev/personal/notes/content";
    };

  };

}
