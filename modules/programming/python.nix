{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      # python310 # Standard Python interpreter
      nodePackages.pyright # Python language server
      black # Python formatter
    ];

    programs.fish.shellAbbrs = { py = "python"; };

  };

}
