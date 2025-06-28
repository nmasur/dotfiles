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
    home.packages = [
      pkgs.age # Encryption
      pkgs.bc # Calculator
      pkgs.bottom # System monitor (top)
      pkgs.delta # Fancy diffs
      pkgs.difftastic # Other fancy diffs
      pkgs.doggo # DNS client (dig)
      pkgs.du-dust # Disk usage tree (ncdu)
      pkgs.dua # File sizes (du)
      pkgs.duf # Basic disk information (df)
      pkgs.jless # JSON viewer
      pkgs.jo # JSON output
      pkgs.mpd # TUI slideshows
      pkgs.nmasur.jqr # FZF fq JSON tool
      pkgs.nmasur.osc # Clipboard over SSH
      # pkgs.nmasur.ren-find # Rename files
      # pkgs.nmasur.rep-grep # Replace text in files
      pkgs.pandoc # Convert text documents
      pkgs.qrencode # Generate qr codes
      pkgs.spacer # Output lines in terminal
      pkgs.tealdeer # Cheatsheets
      pkgs.tree # Print tree in terminal
      pkgs.vimv-rs # Batch rename files
    ];

    programs.fish.shellAliases = {
      "du" = lib.mkDefault (lib.getExe pkgs.dua);
      "ncdu" = lib.mkDefault (lib.getExe pkgs.du-dust);
      "df" = lib.mkDefault (lib.getExe pkgs.duf);

      # Use eza (exa) instead of ls for fancier output
      ls = lib.mkDefault "${lib.getExe pkgs.eza} --group";

      # Version of bash which works much better on the terminal
      bash = lib.mkDefault (lib.getExe pkgs.bashInteractive);
    };

    nmasur.presets.programs = {
      atuin.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      dotfiles.enable = lib.mkDefault true;
      fd.enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      helix.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      nix-index.enable = lib.mkDefault true;
      nixpkgs.enable = lib.mkDefault true;
      notes.enable = lib.mkDefault true;
      prettyping.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      weather.enable = lib.mkDefault true;
      yt-dlp.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
    };

  };
}
