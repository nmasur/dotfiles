{ config, lib, ... }: {

  home-manager.users.${config.user} = {

    programs.fish = {
      shellAbbrs = {
        nr = lib.mkForce "rebuild-darwin";
        nro = lib.mkForce "rebuild-darwin offline";
      };
      functions = {
        rebuild-darwin = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            commandline --replace "git -C ${config.dotfilesPath} add --all"
            commandline --append "
            darwin-rebuild switch $option --flake ${config.dotfilesPath}#macbook"
            commandline --function execute
          '';
        };
      };
    };

  };

}
