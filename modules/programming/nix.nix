{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      nixfmt # Nix file formatter
      nil # Nix language server
    ];

  };

}
