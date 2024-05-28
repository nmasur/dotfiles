{
  config,
  pkgs,
  lib,
  ...
}:
{

  home-manager.users.${config.user} = {

    programs.gh = lib.mkIf config.home-manager.users.${config.user}.programs.git.enable {
      enable = true;
      gitCredentialHelper.enable = true;
      settings.git_protocol = "https";
      extensions = [
        pkgs.gh-collaborators
        pkgs.gh-dash
      ];
    };

    programs.fish = lib.mkIf config.home-manager.users.${config.user}.programs.gh.enable {
      shellAbbrs = {
        ghr = "gh repo view -w";
        gha = "gh run list | head -1 | awk '{ print \\$\\(NF-2\\) }' | xargs gh run view";
        grw = "gh run watch";
        grf = "gh run view --log-failed";
        grl = "gh run view --log";
        ghpr = "gh pr create && sleep 3 && gh run watch";

        # https://github.com/cli/cli/discussions/4067
        prs = "gh search prs --state=open --review-requested=@me";
      };
      functions = {
        repos = {
          description = "Clone GitHub repositories";
          argumentNames = "organization";
          body = ''
            set directory (gh-repos $organization)
            and cd $directory
          '';
        };
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "gh-repos" ''
        case $1 in
            t2) organization="take-two" ;;
            d2c) organization="take-two-t2gp" ;;
            t2gp) organization="take-two-t2gp" ;;
            pd) organization="private-division" ;;
            dots) organization="playdots" ;;
            *) organization="nmasur" ;;
        esac

        selected=$(gh repo list "$organization" \
            --limit 100 \
            --no-archived \
            --json=name,description,isPrivate,updatedAt,primaryLanguage \
            | jq -r '.[] | .name + "," + if .description == "" then "-" else .description |= gsub(","; " ") | .description end + "," + .updatedAt + "," + .primaryLanguage.name' \
            | (echo "REPO,DESCRIPTION,UPDATED,LANGUAGE"; cat -) \
            | column -s , -t \
            | fzf \
                --header-lines=1 \
                --layout=reverse \
                --height=100% \
                --bind "ctrl-o:execute:gh repo view -w ''${organization}/{1}" \
                --bind "shift-up:preview-half-page-up" \
                --bind "shift-down:preview-half-page-down" \
                --preview "GH_FORCE_TTY=49% gh repo view ''${organization}/{1} | glow -" \
                --preview-window up
        )
        [ -n "''${selected}" ] && {
            directory="$HOME/dev/work"
            if [ $organization = "nmasur" ]; then directory="$HOME/dev/personal"; fi
            repo=$(echo "''${selected}" | awk '{print $1}')
            repo_full="''${organization}/''${repo}"
            if [ ! -d "''${directory}/''${repo}" ]; then
                gh repo clone "$repo_full" "''${directory}/''${repo}"
            fi
            echo "''${directory}/''${repo}"
        }
      '')
    ];
  };
}
