{ pkgs, ... }: {

  users.users."${user}" = { # macOS user
    home = "/Users/${user}";
    shell = pkgs.zsh; # Default shell
  };

  networking = {
    computerName = "MacBook"; # Host name
    hostName = "MacBook";
  };

}
