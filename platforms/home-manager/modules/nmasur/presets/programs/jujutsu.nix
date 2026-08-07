{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.jujutsu;
  tomlFormat = pkgs.formats.toml { };
in

{

  options.nmasur.presets.programs.jujutsu.enable = lib.mkEnableOption "Jujutsu version control";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;

      # https://github.com/martinvonz/jj/blob/main/docs/config.md
      settings = {
        user = {
          name = config.programs.git.settings.user.name;
          email = config.programs.git.settings.user.email;
        };
        ui.paginate = "never";

        # Automatically snapshot when files change
        fsmonitor.backend = "watchman";
        fsmonitor.watchman.register-snapshot-trigger = true;
      };
    };

    xdg.configFile."jjui/config.toml".source = tomlFormat.generate "jjui-config" {
      actions = [
        {
          name = "set-github-bypass";
          lua = ''
            exec_shell([[gh api --method PATCH -H "Accept: application/vnd.github+json" /repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/properties/values -f 'properties[][property_name]=Allow-Ruleset-Bypass' -f 'properties[][value]=true']])
            flash("Set GitHub rule bypass")
          '';
          key = "ctrl+b";
          scope = "revisions";
          desc = "Set GitHub rule bypass";
        }
        {
          name = "remove-github-bypass";
          lua = ''
            exec_shell([[gh api --method PATCH -H "Accept: application/vnd.github+json" /repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/properties/values -f 'properties[][property_name]=Allow-Ruleset-Bypass' -f 'properties[][value]=']])
            flash("Removed GitHub rule bypass")
          '';
          key = "ctrl+shift+b";
          scope = "revisions";
          desc = "Remove GitHub rule bypass";
        }
      ];
    };

    home.packages = [
      # Required for the fsmonitor to auto-snapshot
      pkgs.watchman

      # Required to be on path to work in Zellij
      pkgs.jjui
    ];

  };
}
