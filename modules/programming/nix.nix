{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs;
      [
        nixfmt # Nix file formatter
      ];

    programs.fish.shellAbbrs = { n = "nix"; };

  };

}
