{ config, pkgs, ... }: {

  users.users."${config.user}" = { # macOS user
    home = "/Users/${config.user}";
    shell = pkgs.zsh; # Default shell
  };

}
