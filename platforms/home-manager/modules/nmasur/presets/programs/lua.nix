{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.lua;
in
{

  options.nmasur.presets.programs.lua.enable = lib.mkEnableOption "Lua programming language.";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.stylua # Lua formatter
      pkgs.sumneko-lua-language-server # Lua LSP
    ];
  };
}
