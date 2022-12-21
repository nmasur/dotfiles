{ config, pkgs, lib, ... }: {

  options.charm.enable = lib.mkEnableOption "Charm utilities.";

  config.home-manager.users.${config.user} = lib.mkIf config.charm.enable {

    home.packages = with pkgs; [
      glow # Markdown previews
      skate # Key-value store
      charm # Manage account and filesystem
    ];

  };

}
