{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nixpkgs;
in

{

  options.nmasur.presets.programs.nixpkgs.enable = lib.mkEnableOption "Nixpkgs presets";

  config = lib.mkIf cfg.enable {

    programs.fish = {
      shellAbbrs = {
        n = "nix";
        ns = "nix-shell -p";
        nsf = "nix-shell --run fish -p";
        nsr = "nix-shell-run";
        nps = "nix repl --expr 'import <nixpkgs>{}'";
        nixo = "man configuration.nix";
        nixh = "man home-configuration.nix";
        nr = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          function = "rebuild-nixos";
        };
        nro = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          function = "rebuild-nixos-offline";
        };
        hm = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          function = "rebuild-home";
        };
      };
      functions = {
        nix-shell-run = {
          body = # fish
            ''
              set program $argv[1]
              if test (count $argv) -ge 2
                  commandline -r "nix run nixpkgs#$program -- $argv[2..-1]"
              else
                  commandline -r "nix run nixpkgs#$program"
              end
              commandline -f execute
            '';
        };
        nix-fzf = {
          body = # fish
            ''
              commandline -i (nix-instantiate --eval --json \
                -E 'builtins.attrNames (import <nixpkgs> {})' \
                | ${lib.getExe pkgs.jq} '.[]' -r | ${lib.getExe pkgs.fzf})
              commandline -f repaint
            '';
        };
        rebuild-nixos = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          body = # fish
            ''
              git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
              echo "doas nixos-rebuild switch --flake ${config.nmasur.presets.programs.dotfiles.path}#${config.networking.hostName}"
            '';
        };
        rebuild-nixos-offline = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          body = # fish
            ''
              git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
              echo "doas nixos-rebuild switch --option substitute false --flake ${config.nmasur.presets.programs.dotfiles.path}#${config.networking.hostName}"
            '';
        };
        rebuild-home = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          body = # fish
            ''
              git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
              echo "${lib.getExe pkgs.home-manager} switch --flake ${config.nmasur.presets.programs.dotfiles.path}#${config.networking.hostName}";
            '';
        };
      };
    };

    config.nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        # Ctrl-n
        bind -M insert \cn 'commandline -r "nix shell nixpkgs#"'
        bind -M default \cn 'commandline -r "nix shell nixpkgs#"'
        # Ctrl-Shift-n (defined by terminal)
        bind -M insert \x11F nix-fzf
        bind -M default \x11F nix-fzf
      '';

    # Provides "command-not-found" options
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    # Create nix-index if doesn't exist
    home.activation.createNixIndex =
      let
        cacheDir = "${config.xdg.cacheHome}/nix-index";
      in
      lib.mkIf config.programs.nix-index.enable (
        config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${cacheDir} ]; then
              $DRY_RUN_CMD ${pkgs.nix-index}/bin/nix-index -f ${pkgs.path}
          fi
        ''
      );

    # Set automatic generation cleanup for home-manager
    nix.gc = {
      automatic = config.nix.gc.automatic;
      options = config.nix.gc.options;
    };
  };

  nix = {

    # Set channel to flake packages, used for nix-shell commands
    nixPath = [ "nixpkgs=${pkgs.path}" ];

    # For security, only allow specific users
    settings.allowed-users = [
      "@wheel" # Anyone in the wheel group
      config.user # The current user
    ];

    # Enable features in Nix commands
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

    settings = {

      # Add community Cachix to binary cache
      # Don't use at work because blocked by corporate firewall
      builders-use-substitutes = true;
      substituters = lib.mkIf (!config.nmasur.profiles.work.enable) [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = lib.mkIf (!config.nmasur.profiles.work.enable) [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Scans and hard links identical files in the store
      # Not working with macOS: https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = lib.mkIf (!pkgs.stdenv.isDarwin) true;
    };

  };
}
