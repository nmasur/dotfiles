{ lib, ... }: {

  imports = [
    ./system.nix
    ./user.nix
    ./tmux.nix
    ./utilities.nix
    ./hammerspoon.nix
    ./alacritty.nix
    ./homebrew.nix
  ];

  options = with lib; {

    user = mkOption {
      type = types.str;
      description = "Primary user of the system";
    };

    gui = {
      enable = mkEnableOption {
        description = "Enable graphics";
        default = false;
      };

      colorscheme = mkOption {
        type = types.attrs;
        description = "Base16 color scheme";
      };

    };
  };

}
