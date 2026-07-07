{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.darwin-gaming;
in

{

  options.nmasur.profiles.darwin-gaming.enable = lib.mkEnableOption "gaming config for macOS";

  config = lib.mkIf cfg.enable {

    home.file.".Brewfile".text = /* homebrew */ ''
      # Casks (GUI Apps)
      cask "steam" # Not packaged for Nix on macOS
      cask "epic-games" # Not packaged for Nix
    '';

  };
}
