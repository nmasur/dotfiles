{ config, lib, ... }:

let
  cfg = config.nmasur.presets.programs.notmuch;
in

{

  options.nmasur.presets.programs.notmuch.enable = lib.mkEnableOption "Notmuch mail indexing";

  config = lib.mkIf cfg.enable {
    # Better local mail search
    programs.notmuch = {
      enable = true;
      new.ignore = [
        ".mbsyncstate.lock"
        ".mbsyncstate.journal"
        ".mbsyncstate.new"
      ];
    };

  };

}
