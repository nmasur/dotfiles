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
        body = lib.getExe (
          pkgs.writers.writeFishBin "syncnotes" {
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              "${lib.makeBinPath [ pkgs.git ]}"
            ];
          } (builtins.readFile ./syncnotes.fish)
        );
      };
      note = {
        description = "Edit or create a note";
        argumentNames = "filename";
        body = lib.getExe (
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
          } (builtins.readFile ./note.fish)
        );
      };
      generate-today = {
        description = "Create today's note";
        body = # fish
          ''
            set filename $(date +%Y-%m-%d_%a)
            set filepath "${cfg.path}/content/journal/$filename.md"
            if ! test -e "$filepath"
              echo -e  "---\ntitle: $(date +"%A, %B %e %Y") - $(curl "https://wttr.in/New+York+City?u&format=1")\ntags: [ journal ]\n---\n\n" > "$filepath"
            end
            echo "$filepath"
          '';
      };
      today = {
        description = "Edit or create today's note";
        body = lib.getExe (
          pkgs.writers.writeFishBin "today"
            {
              makeWrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                "${lib.makeBinPath [
                  pkgs.curl
                  pkgs.helix
                ]}"
              ];
            } # fish
            ''
              set filename $(date +%Y-%m-%d_%a)
              set filepath "${cfg.path}/content/journal/$filename.md"
              if ! test -e "$filepath"
                echo -e  "---\ntitle: $(date +"%A, %B %e %Y") - $(curl "https://wttr.in/New+York+City?u&format=1")\ntags: [ journal ]\n---\n\n" > "$filepath"
              end
              hx "$filepath"
            ''
        );
      };
    };
  };
}
