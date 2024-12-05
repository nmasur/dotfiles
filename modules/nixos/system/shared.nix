{ config, lib, ... }:
{

  config = lib.mkIf config.server {

    # Create a shared group for many services
    users.groups.shared = { };

    # Give the human user access to the shared group
    users.users.${config.user}.extraGroups = [ config.users.groups.shared.name ];

  };

}
