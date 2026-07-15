{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs._1password;
in

{
  options.nmasur.presets.programs._1password.enable = lib.mkEnableOption "1Password password manager";

  config = lib.mkIf cfg.enable {
    # Unfree packages are already permitted via the shared nixpkgs instance
    # created in lib/default.nix (config.allowUnfree = true). Setting
    # nixpkgs.config here would conflict with nixpkgs.pkgs being set externally.
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      # polkitPolicyOwners = [ "yourUsernameHere" ];
    };
  };
}
