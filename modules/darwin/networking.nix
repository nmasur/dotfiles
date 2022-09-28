{ config, ... }: {

  networking = {
    computerName = "${config.fullName}'\\''s Mac";
    hostName = "${config.user}-mac";
  };

}
