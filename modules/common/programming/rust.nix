{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.rust.enable = lib.mkEnableOption "Rust programming language.";

  config = lib.mkIf config.rust.enable {

    home-manager.users.${config.user} = {

      programs.fish.shellAbbrs = {
        ca = "cargo";
      };

      home.packages = with pkgs; [
        cargo
        rustc
        clippy
        gcc
      ];
    };
  };
}
