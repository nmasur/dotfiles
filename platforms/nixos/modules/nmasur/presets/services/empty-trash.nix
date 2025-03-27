{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.empty-trash;
in

{

  options.nmasur.presets.services.empty-trash.enable = lib.mkEnableOption "automatically empty trash";

  config = lib.mkIf cfg.enable {

    # Delete Trash files older than 1 week
    systemd.user.services.empty-trash = {
      description = "Empty Trash on a regular basis";
      wantedBy = [ "default.target" ];
      script = "${pkgs.trash-cli}/bin/trash-empty 7";
    };
  };
}
