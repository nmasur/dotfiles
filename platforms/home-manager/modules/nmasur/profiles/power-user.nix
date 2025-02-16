{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.power-user;
in
{
  options.nmasur.profiles.power-user.enable = lib.mkEnableOption "power user home-manager config";

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
      pkgs.ren # Rename files
      pkgs.rep # Replace text in files
      pkgs.spacer # Output lines in terminal
      pkgs.tealdeer # Cheatsheets
      pkgs.vimv-rs # Batch rename files
      pkgs.dua # File sizes (du)
      pkgs.du-dust # Disk usage tree (ncdu)
      pkgs.duf # Basic disk information (df)
      pkgs.pandoc # Convert text documents
      pkgs.mpd # TUI slideshows
      pkgs.doggo # DNS client (dig)
      pkgs.bottom # System monitor (top)
    ];

    programs.fish.shellAliases = {
      "cd" = lib.mkDefault lib.getExe pkgs.zoxide;
      "du" = lib.mkDefault lib.getExe pkgs.dua;
      "ncdu" = lib.mkDefault lib.getExe pkgs.du-dust;
      "df" = lib.mkDefault lib.getExe pkgs.duf;

      # Use eza (exa) instead of ls for fancier output
      ls = lib.mkDefault "${lib.getExe pkgs.eza} --group";

      # Version of bash which works much better on the terminal
      bash = lib.mkDefault lib.getExe pkgs.bashInteractive;
    };

    nmasur.presets.programs = {
      atuin.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      dotfiles.enable = lib.mkDefault true;
      fd.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      prettyping.enable = lib.mkDefault true;
      weather.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
    };

  };
}
