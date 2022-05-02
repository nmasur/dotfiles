{ identity, ... }: {
  home-manager.users.${identity.user} = {

    home.sessionVariables = {
      NOTES_PATH = "/home/${identity.user}/dev/personal/notes";
    };

  };

}
