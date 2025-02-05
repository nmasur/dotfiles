{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.user;
in

{

  options.nmasur.presets.services.user.enable = lib.mkEnableOption "macoS user settings";

  config = lib.mkIf cfg.enable {
    users.users."${config.user}" = {
      # macOS user
      home = config.home-manager.users.${config.user}.home.homeDirectory;
      uid = 502;
      # shell = pkgs.fish; # Default shell
    };
    # This might fix the shell issues
    users.knownUsers = [ config.user ];

  };
}
