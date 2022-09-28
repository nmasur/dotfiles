{ config, ... }: {

  networking = {
    computerName = "${config.fullName}'\\''s Mac";
    # Adjust if necessary
    # hostName = "";
  };

}
