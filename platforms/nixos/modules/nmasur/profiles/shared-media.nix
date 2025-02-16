{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.profiles.shared-media;
in

{

  options.nmasur.profiles.shared-media.enable = lib.mkEnableOption "shared media groups";

  config = lib.mkIf cfg.enable {

    # Create a shared group for many services
    users.groups.shared = { };

    # Give the human user access to the shared group
    users.users.${username}.extraGroups = [ config.users.groups.shared.name ];

  };
}
