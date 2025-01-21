{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.common;
in
{
  options.nmasur.profiles.common.enable = lib.mkEnableOption "Extra home-manager config";

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkDefault [
      pkgs.age # Encryption
      pkgs.bc # Calculator
      pkgs.delta # Fancy diffs
      pkgs.difftastic # Other fancy diffs
      pkgs.jless # JSON viewer
      pkgs.jo # JSON output
      pkgs.osc # Clipboard over SSH
      pkgs.qrencode # Generate qr codes
      # pkgs.ren # Rename files
      # pkgs.rep # Replace text in files
      pkgs.spacer # Output lines in terminal
      pkgs.tealdeer # Cheatsheets
      pkgs.vimv-rs # Batch rename files
      pkgs.dua # File sizes (du)
      pkgs.du-dust # Disk usage tree (ncdu)
      pkgs.duf # Basic disk information (df)
      pkgs.pandoc # Convert text documents
      pkgs.mpd # TUI slideshows
    ];

    programs.zoxide.enable = lib.mkDefault true; # Shortcut jump command
    programs.fish.shellAliases = {
      "cd" = lib.mkDefault "${pkgs.zoxide}/bin/zoxide";
      "du" = lib.mkDefault "${pkgs.dua}/bin/dua";
      "ncdu" = lib.mkDefault "${pkgs.du-dust}/bin/du-dust";
      "df" = lib.mkDefault "${pkgs.duf}/bin/duf";

      # Use eza (exa) instead of ls for fancier output
      ls = "${pkgs.eza}/bin/eza --group";

      # Version of bash which works much better on the terminal
      bash = "${pkgs.bashInteractive}/bin/bash";
    };

    config.nmasur.presets.bat.enable = lib.mkDefault true;
    config.nmasur.presets.fd.enable = lib.mkDefault true;
    config.nmasur.presets.ripgrep.enable = lib.mkDefault true;
    config.nmasur.presets.prettyping.enable = lib.mkDefault true;
    config.nmasur.presets.weather.enable = lib.mkDefault true;

  };
}
