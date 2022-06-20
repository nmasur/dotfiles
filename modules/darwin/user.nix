{ config, pkgs, lib, ... }: {

  users.users."${config.user}" = { # macOS user
    home = "/Users/${config.user}";
    shell = pkgs.zsh; # Default shell
  };

  home-manager.users.${config.user} = {

    accounts.email.accounts.home = {
      passwordCommand = lib.mkForce
        "${pkgs.age}/bin/age --decrypt --identity /Users/${config.user}/.ssh/id_ed25519 ${
          builtins.toString ./mailpass.age
        }";
    };

  };

}
