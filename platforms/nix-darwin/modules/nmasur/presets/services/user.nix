{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.presets.services.user;
in

{

  options.nmasur.presets.services.user.enable = lib.mkEnableOption "macoS user settings";

  config = lib.mkIf cfg.enable {
    users.users."${username}" = {
      # macOS user
      home = "/Users/${username}";
      uid = 502;
      # shell = pkgs.fish; # Default shell
    };
    # This might fix the shell issues
    users.knownUsers = [ username ];

  };
}
