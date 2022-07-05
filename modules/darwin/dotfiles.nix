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
            git -C ${config.dotfilesPath} add --all
            commandline -r "darwin-rebuild switch $option --flake ${config.dotfilesPath}#macbook"
            commandline --function execute
          '';
        };
      };
    };

  };

}
