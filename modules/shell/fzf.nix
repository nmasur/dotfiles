{ config, ... }: {

  home-manager.users.${config.user} = {

    programs.fzf.enable = true;

    programs.fish = {
      functions = {
        projects = {
          description = "Jump to a project";
          body = ''
            set projdir (ls /home/${config.user}/dev/personal | fzf)
            and cd /home/${config.user}/dev/personal/$projdir
            and commandline -f execute
          '';
        };
      };
      shellAbbrs = { lf = "ls -lh | fzf"; };
    };

    home.sessionVariables = let fzfCommand = "fd --type file";
    in {
      FZF_DEFAULT_COMMAND = fzfCommand;
      FZF_CTRL_T_COMMAND = fzfCommand;
      FZF_DEFAULT_OPTS = "-m --height 50% --border";
    };

  };

}
