{ config, pkgs, ... }: {
  home-manager.users.${config.user} = {

    programs.fish = {
      shellAbbrs = {
        n = "nix";
        ns = "nix-shell --run fish -p";
        nsr = "nix-shell-run";
        nps = "nix repl '<nixpkgs>'";
        nixo = "man configuration.nix";
        nixh = "man home-configuration.nix";
        nr = "rebuild-nixos";
        nro = "rebuild-nixos offline";
      };
      functions = {
        nix-shell-run = {
          body = ''
            set program $argv[1]
            if test (count $argv) -ge 2
                commandline -r "nix run github:NixOS/nixpkgs/nixpkgs-unstable#$program -- $argv[2..-1]"
            else
                commandline -r "nix run github:NixOS/nixpkgs/nixpkgs-unstable#$program"
            end
            commandline -f execute
          '';
        };
        nix-fzf = {
          body = ''
            commandline -i (nix-instantiate --eval --json \
              -E 'builtins.attrNames (import <nixpkgs> {})' \
              | jq '.[]' -r | fzf)
            commandline -f repaint
          '';
        };
        rebuild-nixos = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            git -C ${config.dotfilesPath} add --intent-to-add --all
            commandline -r "doas nixos-rebuild switch $option --flake ${config.dotfilesPath}"
            commandline --function execute
          '';
        };
      };
    };

    # Provides "command-not-found" options
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

  };

  # Set system channels, used for nix-shell commands
  nix = { nixPath = [ "nixpkgs=${pkgs.path}" ]; };

}
