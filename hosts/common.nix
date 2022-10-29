{ config, lib, pkgs, ... }: {

  imports =
    [ ../modules/shell ../modules/neovim ../modules/repositories/dotfiles.nix ];

  options = with lib; {
    user = mkOption {
      type = types.str;
      description = "Primary user of the system";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Human readable name of the user";
    };
    userDirs = {
      # Required to prevent infinite recursion when referenced by himalaya
      download = lib.mkOption {
        type = lib.types.str;
        description = "XDG directory for downloads";
        default =
          if pkgs.stdenv.isDarwin then "$HOME/Downloads" else "$HOME/downloads";
      };
    };
    identityFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to existing private key file.";
      default = "/etc/ssh/ssh_host_ed25519_key";
    };
    gui = {
      enable = mkEnableOption {
        description = "Enable graphics";
        default = false;
      };
    };
    colorscheme = mkOption {
      type = types.attrs;
      description = "Base16 color scheme";
    };
    homePath = mkOption {
      type = types.path;
      description = "Path of user's home directory.";
      default = builtins.toPath (if pkgs.stdenv.isDarwin then
        "/Users/${config.user}"
      else
        "/home/${config.user}");
    };

    dotfilesPath = mkOption {
      type = types.path;
      description = "Path of dotfiles repository.";
      default = config.homePath + "/dev/personal/dotfiles";
    };
    dotfilesRepo = mkOption {
      type = types.str;
      description = "Link to dotfiles repository.";
    };
    unfreePackages = mkOption {
      type = types.listOf types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
  };

  config = let stateVersion = "22.11";
  in {

    # Enable features in Nix commands
    nix.extraOptions = "experimental-features = nix-command flakes";

    # Basic common system packages for all devices
    environment.systemPackages = with pkgs; [ git vim wget curl ];

    # Use the system-level nixpkgs instead of Home Manager's
    home-manager.useGlobalPkgs = true;

    # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
    # using multiple profiles for one user
    home-manager.useUserPackages = true;

    # Allow specified unfree packages (identified elsewhere)
    # Retrieves package object based on string name
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.unfreePackages;

    # Pin a state version to prevent warnings
    home-manager.users.${config.user}.home.stateVersion = stateVersion;
    home-manager.users.root.home.stateVersion = stateVersion;

  };

}
