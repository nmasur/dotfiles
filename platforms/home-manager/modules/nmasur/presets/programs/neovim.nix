{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.neovim;
in

{

  options.nmasur.presets.programs.neovim = {
    enable = lib.mkEnableOption "Neovim text editor";
    package = lib.mkPackageOption pkgs "neovim" { };
    colors = lib.mkOption {
      type = lib.types.attrs;
      description = "Base16 color scheme.";
      default = config.theme.colors;
    };
    github.enable = lib.mkEnableOption "GitHub integration";
    terraform.enable = lib.mkEnableOption "Terraform integration";
    kubernetes.enable = lib.mkEnableOption "Kubernetes integration";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ cfg.package ];

    cfg.package = lib.mkDefault pkgs.nmasur-neovim.override {
      colors = cfg.colors;
      github = cfg.github.enable;
      terraform = cfg.terraform.enable;
      kubernetes = cfg.kubernetes.enable;
    };

    # Use Neovim as the editor for git commit messages
    programs.git.extraConfig.core.editor = "${lib.getExe cfg.package}";
    programs.jujutsu.settings.ui.editor = "${lib.getExe cfg.package}";

    # Set Neovim as the default app for text editing and manual pages
    home.sessionVariables = {
      EDITOR = "${lib.getExe cfg.package}";
      MANPAGER = "${lib.getExe cfg.package} +Man!";
    };

    # Create quick aliases for launching Neovim
    programs.fish = {
      shellAliases = {
        vim = "${lib.getExe cfg.package}";
        nvim = "${lib.getExe cfg.package}";
      };
      shellAbbrs = {
        v = lib.mkForce "nvim";
        vl = lib.mkForce "nvim -c 'normal! `0' -c 'bdelete 1'";
        vll = "nvim -c 'Telescope oldfiles'";
      };
    };

    # Create a desktop option for launching Neovim from a file manager
    # (Requires launching the terminal and then executing Neovim)
    xdg.desktopEntries.nvim = lib.mkIf (pkgs.stdenv.isLinux) {
      name = "Neovim wrapper";
      exec = "${lib.getExe config.nmasur.presets.services.i3.terminal} nvim %F"; # TODO: change to generic
      mimeType = [
        "text/plain"
        "text/markdown"
      ];
    };
    xdg.mimeApps.defaultApplications = {
      "text/plain" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
    };

  };

}
