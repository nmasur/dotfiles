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

    programs.fzf.enable = true;

    programs.fish = {
      functions = {
        projects = {
          description = "Jump to a project";
          body = ''
            set projdir ( \
                fd \
                    --search-path $HOME/dev \
                    --type directory \
                    --exact-depth 2 \
                | ${pkgs.proximity-sort}/bin/proximity-sort $PWD \
                | sed 's/\\/$//' \
                | fzf --tiebreak=index \
            )
            and cd $projdir
            and commandline -f execute
          '';
        };
      };
      shellAbbrs = {
        lsf = "ls -lh | fzf";
      };
    };

    # Global fzf configuration
    home.sessionVariables =
      let
        fzfCommand = "fd --type file";
      in
      {
        FZF_DEFAULT_COMMAND = fzfCommand;
        FZF_CTRL_T_COMMAND = fzfCommand;
        FZF_DEFAULT_OPTS = "-m --height 50% --border";
      };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "jqr";
        runtimeInputs = [
          pkgs.jq
          pkgs.fzf
        ];
        text = builtins.readFile ./bash/scripts/jqr.sh;
      })
    ];

  };
}
