{ config, ... }: {

  home-manager.users.${config.user}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        prefix = [ "/home/${config.user}/dev/personal/dotfiles/" ];
      };
    };
  };

}
