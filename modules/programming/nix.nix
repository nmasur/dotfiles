{ config, pkgs, lib, ... }: {

  options.nixlang.enable = lib.mkEnableOption "Nix programming language.";

  config = lib.mkIf config.nixlang.enable {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        nixfmt # Nix file formatter
        nil # Nix language server
      ];

    };

  };

}
