{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    programs.gh =
      lib.mkIf config.home-manager.users.${config.user}.programs.git.enable {
        enable = true;
        enableGitCredentialHelper = true;
        settings.git_protocol = "https";
      };

    programs.fish =
      lib.mkIf config.home-manager.users.${config.user}.programs.gh.enable {
        shellAbbrs = {
          ghr = "gh repo view -w";
          gha =
            "gh run list | head -1 | awk '{ print $(NF-2) }' | xargs gh run view";
          grw = "gh run watch";
          grf = "gh run view --log-failed";
          grl = "gh run view --log";
          ghpr = "gh pr create && sleep 3 && gh run watch";
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

  };

}
