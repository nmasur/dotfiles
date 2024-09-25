{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./applications
    ./mail
    ./neovim
    ./programming
    ./repositories
    ./shell
  ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
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
        default = if pkgs.stdenv.isDarwin then "$HOME/Downloads" else "$HOME/downloads";
      };
    };
    identityFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to existing private key file.";
      default = "/etc/ssh/ssh_host_ed25519_key";
    };
    gui = {
      enable = lib.mkEnableOption {
        description = "Enable graphics.";
        default = false;
      };
    };
    theme = {
      colors = lib.mkOption {
        type = lib.types.attrs;
        description = "Base16 color scheme.";
        default = (import ../colorscheme/gruvbox).dark;
      };
      dark = lib.mkOption {
        type = lib.types.bool;
        description = "Enable dark mode.";
        default = true;
      };
    };
    homePath = lib.mkOption {
      type = lib.types.path;
      description = "Path of user's home directory.";
      default = builtins.toPath (
        if pkgs.stdenv.isDarwin then "/Users/${config.user}" else "/home/${config.user}"
      );
    };
    dotfilesPath = lib.mkOption {
      type = lib.types.path;
      description = "Path of dotfiles repository.";
      default = config.homePath + "/dev/personal/dotfiles";
    };
    dotfilesRepo = lib.mkOption {
      type = lib.types.str;
      description = "Link to dotfiles repository HTTPS URL.";
    };
    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
    hostnames = {
      files = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for files server (Filebrowser).";
      };
      git = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for git server (Gitea).";
      };
      metrics = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for metrics server.";
      };
      minecraft = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for Minecraft server.";
      };
      paperless = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for document server (paperless-ngx).";
      };
      prometheus = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for Prometheus server.";
      };
      influxdb = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for InfluxDB2 server.";
      };
      secrets = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for passwords and secrets (Vaultwarden).";
      };
      stream = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for video/media library (Jellyfin).";
      };
      content = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for personal content system (Nextcloud).";
      };
      books = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for books library (Calibre-Web).";
      };
      download = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for download services.";
      };
      irc = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for IRC services.";
      };
      n8n = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for n8n automation.";
      };
      notifications = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for push notification services (ntfy).";
      };
      status = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for status page (Uptime-Kuma).";
      };
      transmission = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for peer2peer downloads (Transmission).";
      };
    };
  };

  config =
    let
      stateVersion = "23.05";
    in
    {

      # Basic common system packages for all devices
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
      ];

      # Use the system-level nixpkgs instead of Home Manager's
      home-manager.useGlobalPkgs = true;

      # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      home-manager.useUserPackages = true;

      # Allow specified unfree packages (identified elsewhere)
      # Retrieves package object based on string name
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      # Pin a state version to prevent warnings
      home-manager.users.${config.user}.home.stateVersion = stateVersion;
      home-manager.users.root.home.stateVersion = stateVersion;
    };
}
