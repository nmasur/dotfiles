{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      # python310 # Standard Python interpreter
      nodePackages.pyright # Python language server
      black # Python formatter
      python310Packages.flake8 # Python linter
    ];

    programs.fish.shellAbbrs = { py = "python3"; };

  };

}
