{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.notes;
in
{

  options.nmasur.presets.programs.notes = {
    enable = lib.mkEnableOption "Manage notes repository";
    repo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Git repo containing notes";
      default = null;
    };
    path = lib.mkOption {
      type = lib.types.path;
      description = "Path to notes on disk";
      default = config.home.homeDirectory + "/dev/personal/notes";
    };
  };

  config = lib.mkIf cfg.enable {

    home.activation = lib.mkIf (cfg.repo != null) {

      # Always clone notes repository if it doesn't exist
      clonenotes = config.lib.dag.entryAfter [ "writeBoundary" "loadkey" ] ''
        if [ ! -d "${cfg.path}" ]; then
            run mkdir --parents $VERBOSE_ARG $(dirname "${cfg.path}")
            run ${pkgs.git}/bin/git \
                clone ${cfg.repo} "${cfg.path}"
        fi
      '';
    };

    # Set a variable for notes repo, not necessary but convenient
    home.sessionVariables.NOTES_PATH = cfg.path;

    programs.fish.functions = {
      syncnotes = {
        description = "Full git commit on notes";
        body = builtins.readFile lib.getExe (
          pkgs.writers.writeFishBin "syncnotes" {
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [ pkgs.git ]}"
            ];
          } builtins.readFile ./syncnotes.fish
        );
      };
      note = {
        description = "Edit or create a note";
        argumentNames = "filename";
        body = builtins.readFile lib.getExe (
          pkgs.writers.writeFishBin "note" {
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [
                pkgs.vim
                pkgs.fzf
              ]}"
            ];
          } builtins.readFile ./note.fish
        );
      };
    };
  };
}
