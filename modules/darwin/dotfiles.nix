{ config, ... }: {

  home-manager.users.${config.user} = {

    programs.fish = {
      shellAbbrs = {
        nr = "rebuild-darwin";
        nro = "rebuild-darwin offline";
      };
      functions = {
        rebuild-nixos = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            pushd ${config.dotfilesPath}
            git add --all
            popd
            commandline -r darwin-rebuild switch $option --flake ${config.dotfilesPath}#macbook
            commandline -f execute
          '';
        };
      };
    };

  };

}
