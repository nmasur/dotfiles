{ config, pkgs, lib, ... }: {

  options = {
    # identityFile = lib.mkOption {
    #   type = lib.types.str;
    #   description = "Path to SSH key for age";
    #   default = "${config.homePath}/.ssh/id_ed25519";
    # };
  };

  config = {
    home-manager.users.${config.user}.home.packages = with pkgs; [ age ];

    # system.activationScripts.age.text = ''
    #   if [ ! -f "${config.identityFile}" ]; then
    #     $DRY_RUN_CMD echo -e \nEnter the seed phrase for your SSH key...\n
    #     $DRY_RUN_CMD echo -e \nThen press ^D when complete.\n\n
    #     $DRY_RUN_CMD ${pkgs.melt}/bin/melt restore ${config.identityFile}
    #     $DRY_RUN_CMD chown ${config.user}:wheel ${config.identityFile}*
    #     $DRY_RUN_CMD echo -e \n\nContinuing activation.\n\n
    #   fi
    # '';
  };

}
