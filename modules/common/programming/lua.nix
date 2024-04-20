{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.lua.enable = lib.mkEnableOption "Lua programming language.";

  config = lib.mkIf config.lua.enable {
    home-manager.users.${config.user}.home.packages = with pkgs; [
      stylua # Lua formatter
      sumneko-lua-language-server # Lua LSP
    ];
  };
}
