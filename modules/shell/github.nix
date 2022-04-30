{ pkgs, user, ... }: {

  imports = [ ./git.nix ];

  home-manager.users.${user} = {
    programs.gh = {
      enable = true;
      enableGitCredentialHelper = true;
      settings.git_protocol = "https";
    };

    programs.fish = {
      shellAbbrs = {
        ghr = "gh repo view -w";
        gha =
          "gh run list | head -1 | awk '{ print $(NF-2) }' | xargs gh run view";
        grw = "gh run watch";
        grf = "gh run view --log-failed";
        grl = "gh run view --log";
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
