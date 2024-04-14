{
  config,
  pkgs,
  lib,
  ...
}:
{

  # This is just a placeholder as I expect to interact with my notes in a
  # certain location

  home-manager.users.${config.user} = {

    home.sessionVariables = {
      NOTES_PATH = "${config.homePath}/dev/personal/notes/content";
    };

    # Sync notes for Nextcloud automatically
    systemd.user.timers.refresh-notes = lib.mkIf config.services.nextcloud.enable {
      Timer = {
        OnCalendar = "*-*-* *:0/10:50"; # Every 10 minutes
        Unit = "refresh-notes.service";
      };
    };
    systemd.user.services.refresh-notes = {
      Unit.Description = "Get latest notes.";
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.git}/bin/git -C /data/git/notes reset --hard master";
        ExecStart = "${pkgs.git}/bin/git -C /data/git/notes pull";
        WorkingDirectory = config.homePath;
        Environment = "PATH=${pkgs.openssh}/bin";
      };
    };
  };
}
