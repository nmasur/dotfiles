{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.cargo;
in
{

  options.nmasur.presets.programs.cargo.enable = lib.mkEnableOption "Cargo for programming language.";

  config = lib.mkIf cfg.enable {

    programs.fish.shellAbbrs = {
      ca = "cargo";
    };

    home.packages = with pkgs; [
      gcc
      rustc
      cargo
      cargo-watch
      clippy
      rustfmt
      pkg-config
      openssl
    ];
  };
}
