{
  description = "An opinionated flake containing the NixOS, nix-darwin, and home-manager configurations for multiple systems.";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for specific stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # Used for MacOS system config
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for Windows Subsystem for Linux compatibility
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };

    # Community packages; used for Firefox extensions
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Better App install management in macOS
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
    };

    # Manage disk format and partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used to generate NixOS images for other platforms
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Convert Nix to Neovim config
    nix2vim = {
      url = "github:gytis-ivaskevicius/nix2vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # Tree-Sitter Grammars
    # tree-sitter-bash = {
    #   url = "github:tree-sitter/tree-sitter-bash/master";
    #   flake = false;
    # };
    # tree-sitter-python = {
    #   url = "github:tree-sitter/tree-sitter-python/master";
    #   flake = false;
    # };
    # tree-sitter-lua = {
    #   url = "github:MunifTanjim/tree-sitter-lua/main";
    #   flake = false;
    # };
    # tree-sitter-ini = {
    #   url = "github:justinmk/tree-sitter-ini";
    #   flake = false;
    # };
    # tree-sitter-puppet = {
    #   url = "github:amaanq/tree-sitter-puppet";
    #   flake = false;
    # };
    # tree-sitter-rasi = {
    #   url = "github:Fymyte/tree-sitter-rasi";
    #   flake = false;
    # };
    # tree-sitter-vimdoc = {
    #   url = "github:neovim/tree-sitter-vimdoc";
    #   flake = false;
    # };

    # MPV Scripts
    zenyd-mpv-scripts = {
      url = "github:zenyd/mpv-scripts";
      flake = false;
    };

    # # Git alternative
    # # Fixes: https://github.com/martinvonz/jj/issues/4784
    # jujutsu = {
    #   url = "github:martinvonz/jj";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Nextcloud Apps
    nextcloud-news = {
      # https://github.com/nextcloud/news/releases
      url = "https://github.com/nextcloud/news/releases/download/25.0.0-alpha12/news.tar.gz";
      flake = false;
    };
    nextcloud-external = {
      # https://github.com/nextcloud-releases/external/releases
      url = "https://github.com/nextcloud-releases/external/releases/download/v5.5.2/external-v5.5.2.tar.gz";
      flake = false;
    };
    nextcloud-cookbook = {
      # https://github.com/christianlupus-nextcloud/cookbook-releases/releases/
      url = "https://github.com/christianlupus-nextcloud/cookbook-releases/releases/download/v0.11.2/cookbook-0.11.2.tar.gz";
      flake = false;
    };
    nextcloud-snappymail = {
      # https://github.com/the-djmaze/snappymail/releases
      # https://snappymail.eu/repository/nextcloud
      url = "https://snappymail.eu/repository/nextcloud/snappymail-2.38.2-nextcloud.tar.gz";
      # url = "https://github.com/nmasur/snappymail-nextcloud/releases/download/v2.36.3/snappymail-2.36.3-nextcloud.tar.gz";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:

    let
      lib = import ./lib inputs;

      # Global configuration for my systems
      globals =
        let
          baseName = "masu.rs";
        in
        rec {
          user = "noah";
          fullName = "Noah Masur";
          gitName = fullName;
          gitEmail = "7386960+nmasur@users.noreply.github.com";
          dotfilesRepo = "https://github.com/nmasur/dotfiles";
          hostnames = {
            audiobooks = "read.${baseName}";
            books = "books.${baseName}";
            budget = "money.${baseName}";
            content = "cloud.${baseName}";
            download = "download.${baseName}";
            files = "files.${baseName}";
            git = "git.${baseName}";
            imap = "imap.purelymail.com";
            influxdb = "influxdb.${baseName}";
            irc = "irc.${baseName}";
            mail = "noahmasur.com";
            metrics = "metrics.${baseName}";
            minecraft = "minecraft.${baseName}";
            n8n = "n8n.${baseName}";
            notifications = "ntfy.${baseName}";
            paperless = "paper.${baseName}";
            photos = "photos.${baseName}";
            prometheus = "prom.${baseName}";
            secrets = "vault.${baseName}";
            smtp = "smtp.purelymail.com";
            status = "status.${baseName}";
            stream = "stream.${baseName}";
            transmission = "transmission.${baseName}";
          };
        };

    in
    rec {

      inherit lib;

      nixosConfigurations = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module:
          lib.buildNixos {
            inherit system module;
            specialArgs = { inherit (globals) hostnames; };
          }
        ) hosts
      ) lib.linuxHosts;

      # darwinConfigurations = {
      #   aarch64-darwin = {
      #     lookingglass = lib.buildDarwin {
      #       system = "aarch64-darwin";
      #       module = { };
      #       specialArgs = { };
      #     };
      #   };
      # };

      darwinConfigurations = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module:
          lib.buildDarwin {
            inherit system module;
            specialArgs = { inherit (globals) hostnames; };
          }
        ) hosts
      ) lib.darwinHosts;

      homeModules = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module: (builtins.head (lib.attrsToList module.home-manager.users)).value
        ) hosts
      ) lib.hosts;

      homeConfigurations = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module:
          lib.buildHome {
            inherit system module;
            specialArgs = { inherit (globals) hostnames; };
          }
        ) hosts
      ) homeModules;

      # Disk formatting, only used once
      diskoConfigurations = {
        root = import ./hosts/x86_64-linux/swan/root.nix;
      };

      # generators = {
      #   arrow.aws.x86_64-linux = lib.generateImage {
      #     system = "x86_64-linux";
      #     format = "amazon";
      #     specialArgs = { inherit (globals) hostnames; };
      #   };
      #   arrow.iso.x86_64-linux = lib.generateImage {
      #     system = "x86_64-linux";
      #     format = "iso";
      #     specialArgs = { inherit (globals) hostnames; };
      #   };
      # };

      generators = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (name: module: {
          aws = lib.generateImage {
            inherit system module;
            format = "amazon";
            specialArgs = { inherit (globals) hostnames; };
          };
          iso = lib.generateImage {
            inherit system module;
            format = "iso";
            specialArgs = { inherit (globals) hostnames; };
          };
        }) hosts
      ) lib.linuxHosts;

      packages = lib.forAllSystems (
        system:
        # Get the configurations that we normally use
        {
          nixosConfigurations = nixosConfigurations.${system};
          darwinConfigurations = darwinConfigurations.${system};
          homeConfigurations = homeConfigurations.${system};
          generators = generators.${system};
        }
        //
          # Get the custom packages that I have placed under the nmasur namespace
          lib.pkgsBySystem.${system}.nmasur
      );

      # Development environments
      devShells = lib.forAllSystems (system: {
        default = lib.pkgsBySystem.${system}.nmasur.dotfiles-devshell;
      });

      checks = lib.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = lib.overlays;
          };
        in
        {
          neovim =
            pkgs.runCommand "neovim-check-health" { buildInputs = [ inputs.self.packages.${system}.neovim ]; }
              ''
                mkdir -p $out
                export HOME=$TMPDIR
                nvim -c "checkhealth" -c "write $out/health.log" -c "quitall"

                # Check for errors inside the health log
                if $(grep "ERROR" $out/health.log); then
                  cat $out/health.log
                  exit 1
                fi
              '';
        }
      );

      formatter = lib.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            inherit (lib) overlays;
          };
        in
        pkgs.nixfmt-rfc-style
      );

      # Templates for starting other projects quickly
      templates = (import ./templates nixpkgs.lib);
    };
}
