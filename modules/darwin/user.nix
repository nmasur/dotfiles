{ config, pkgs, lib, ... }: {

  users.users."${config.user}" = { # macOS user
    home = config.homePath;
    shell = pkgs.zsh; # Default shell
  };

}
