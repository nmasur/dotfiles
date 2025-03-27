{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fzf;
in

{

  options.nmasur.presets.programs.fzf.enable = lib.mkEnableOption "Fzf fuzzy finder";

  config = lib.mkIf cfg.enable {

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    programs.fish = {
      functions = {
        edit = {
          description = "Open a file in Vim";
          body = # fish
            ''
              set vimfile (fzf)
              and set vimfile (echo $vimfile | tr -d '\r')
              and commandline -r "${builtins.baseNameOf config.home.sessionVariables.EDITOR} \"$vimfile\""
              and commandline -f execute
            '';
        };
        fcd = {
          description = "Jump to directory";
          argumentNames = "directory";
          body = builtins.readFile ./fish/fcd.fish;
        };
        projects = {
          description = "Jump to a project";
          body = # fish
            ''
              set projdir ( \
                  fd \
                      --search-path $HOME/dev \
                      --type directory \
                      --exact-depth 2 \
                  | ${lib.getExe pkgs.proximity-sort} $PWD \
                  | sed 's/\\/$//' \
                  | fzf --tiebreak=index \
              )
              and cd $projdir
              and commandline -f execute
            '';
        };
        recent = {
          description = "Open a recent file in Vim";
          body = # fish
            ''
              set vimfile (fd -t f --exec /usr/bin/stat -f "%m%t%N" | sort -nr | cut -f2 | fzf)
              and set vimfile (echo $vimfile | tr -d '\r')
              and commandline -r "${builtins.baseNameOf config.home.sessionVariables.EDITOR} $vimfile"
              and commandline -f execute
            '';
        };
        search-and-edit = {
          description = "Search and open the relevant file in Vim";
          body = # fish
            ''
              set vimfile ( \
                  rg \
                    --color=always \
                    --line-number \
                    --no-heading \
                    --smart-case \
                    --iglob "!/Library/**" \
                    --iglob "!/System/**" \
                    --iglob "!Users/$HOME/Library/*" \
                    ".*" \
                  | fzf --ansi \
                      --height "80%" \
                      --color "hl:-1:underline,hl+:-1:underline:reverse" \
                      --delimiter : \
                      --preview 'bat --color=always {1} --highlight-line {2}' \
                      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
              )
              and set line_number (echo $vimfile | tr -d '\r' | cut -d':' -f2)
              and set vimfile (echo $vimfile | tr -d '\r' | cut -d':' -f1)
              and commandline -r "${builtins.baseNameOf config.home.sessionVariables.EDITOR} +$line_number \"$vimfile\""
              and commandline -f execute
            '';
        };
      };
      shellAbbrs = {
        lsf = "ls -lh | fzf";
      };
    };

    nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        # Ctrl-o
        bind -M insert \co edit
        bind -M default \co edit
        # Ctrl-s
        bind -M insert \cs search-and-edit
        bind -M default \cs search-and-edit
        # Ctrl-a
        bind -M insert \ca 'cd ~; and edit; and commandline -a "; cd -"; commandline -f execute'
        bind -M default \ca 'cd ~; and edit; and commandline -a "; cd -"; commandline -f execute'
        # Ctrl-e
        bind -M insert \ce recent
        bind -M default \ce recent
        # Ctrl-p
        bind -M insert \cp projects
        bind -M default \cp projects
      '';

    # Global fzf configuration
    home.sessionVariables =
      let
        fzfCommand = "${lib.getExe pkgs.fd} --type file";
      in
      {
        FZF_DEFAULT_COMMAND = fzfCommand;
        FZF_CTRL_T_COMMAND = fzfCommand;
        FZF_DEFAULT_OPTS = "-m --height 50% --border";
      };

  };
}
