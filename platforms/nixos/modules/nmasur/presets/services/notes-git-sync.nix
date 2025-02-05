{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.notes-git-sync;
in

{
  options.nmasur.presets.services.notes-git-sync.enable = lib.mkEnableOption "Sync notes to folder";

  config = lib.mkIf cfg.enable {

    # Sync notes for Nextcloud automatically
    systemd.user.timers.refresh-notes = {
      Timer = {
        OnCalendar = "*-*-* *:0/10:50"; # Every 10 minutes
        Unit = "refresh-notes.service";
      };
    };
    systemd.user.services.refresh-notes = {
      Unit.Description = "Get latest notes.";
      Service = {
        Type = "oneshot";
        ExecStartPre = "${lib.getExe pkgs.git} -C /data/git/notes reset --hard master";
        ExecStart = "${lib.getExe pkgs.git} -C /data/git/notes pull";
        WorkingDirectory = config.home-manager.users.${config.user}.home.homeDirectory;
        Environment = "PATH=${pkgs.openssh}/bin";
      };
    };
  };
}
