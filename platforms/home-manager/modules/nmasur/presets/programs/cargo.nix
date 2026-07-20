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

    home.packages = [
      pkgs.gcc
      pkgs.rustc
      pkgs.cargo
      pkgs.stable.cargo-watch
      pkgs.clippy
      pkgs.rustfmt
      pkgs.pkg-config
      pkgs.openssl
      pkgs.rust-analyzer
    ];
  };
}
