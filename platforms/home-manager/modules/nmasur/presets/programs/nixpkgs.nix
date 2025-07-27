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

  options.nmasur.presets.programs.nixpkgs = {
    enable = lib.mkEnableOption "Nixpkgs presets";
    commands = {
      # These are useful for triggering from zellij (rather than running directly in the shell)
      rebuildHome = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellScriptBin "rebuild-home" ''
          git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
          ${lib.getExe pkgs.home-manager} switch --flake "${config.nmasur.presets.programs.dotfiles.path}#${config.nmasur.settings.host}"
        '';
      };
      rebuildNixos = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellScriptBin "rebuild-nixos" ''
          git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
          doas nixos-rebuild switch --flake ${config.nmasur.presets.programs.dotfiles.path}
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.nh # Allows rebuilding with a cleaner TUI
      cfg.commands.rebuildHome
      cfg.commands.rebuildNixos
    ];

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
              echo "doas nixos-rebuild switch --flake ${config.nmasur.presets.programs.dotfiles.path}"
            '';
        };
        rebuild-nixos-offline = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          body = # fish
            ''
              git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
              echo "doas nixos-rebuild switch --option substitute false --flake ${config.nmasur.presets.programs.dotfiles.path}"
            '';
        };
        rebuild-home = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
          body = # fish
            ''
              git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
              echo "${lib.getExe pkgs.home-manager} switch --flake ${config.nmasur.presets.programs.dotfiles.path}";
            '';
        };
      };
    };

    nmasur.presets.programs.fish.fish_user_key_bindings = # fish
      ''
        # Ctrl-n
        bind -M insert \cn 'commandline -r "nix shell nixpkgs#"'
        bind -M default \cn 'commandline -r "nix shell nixpkgs#"'
        # Ctrl-Shift-n (defined by terminal)
        bind -M insert \x11F nix-fzf
        bind -M default \x11F nix-fzf
      '';

  };

}
