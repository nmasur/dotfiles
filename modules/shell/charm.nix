{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      glow # Markdown previews
      skate # Key-value store
      charm # Manage account and filesystem
    ];

  };

}
