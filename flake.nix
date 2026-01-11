{
  description = "An opinionated flake containing the NixOS, nix-darwin, and home-manager configurations for multiple systems.";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for specific stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

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

    # MPV Scripts
    zenyd-mpv-scripts = {
      url = "github:zenyd/mpv-scripts";
      flake = false;
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
    };

    # Zellij Switcher
    zellij-switch = {
      url = "github:mostafaqanbaryan/zellij-switch";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # # Text editor
    # helix = {
    #   url = "github:helix-editor/helix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.rust-overlay.follows = "rust-overlay";
    # };

    # # Nextcloud Apps
    # nextcloud-news = {
    #   # https://github.com/nextcloud/news/releases
    #   url = "https://github.com/nextcloud/news/releases/download/25.0.0-alpha12/news.tar.gz";
    #   flake = false;
    # };
    # nextcloud-external = {
    #   # https://github.com/nextcloud-releases/external/releases
    #   url = "https://github.com/nextcloud-releases/external/releases/download/v5.5.2/external-v5.5.2.tar.gz";
    #   flake = false;
    # };
    # nextcloud-cookbook = {
    #   # https://github.com/christianlupus-nextcloud/cookbook-releases/releases/
    #   url = "https://github.com/christianlupus-nextcloud/cookbook-releases/releases/download/v0.11.2/cookbook-0.11.2.tar.gz";
    #   flake = false;
    # };
    # nextcloud-snappymail = {
    #   # https://github.com/the-djmaze/snappymail/releases
    #   # https://snappymail.eu/repository/nextcloud
    #   url = "https://snappymail.eu/repository/nextcloud/snappymail-2.38.2-nextcloud.tar.gz";
    #   # url = "https://github.com/nmasur/snappymail-nextcloud/releases/download/v2.36.3/snappymail-2.36.3-nextcloud.tar.gz";
    #   flake = false;
    # };
  };

  outputs =
    { nixpkgs, ... }@inputs:

    let
      hostnames =
        let
          baseName = "masu.rs";
        in
        {
          audiobooks = "read.${baseName}";
          bookmarks = "keep.${baseName}";
          books = "books.${baseName}";
          budget = "money.${baseName}";
          contacts = "contacts.${baseName}";
          content = "cloud.${baseName}";
          download = "download.${baseName}";
          files = "files.${baseName}";
          git = "git.${baseName}";
          imap = "imap.purelymail.com";
          influxdb = "influxdb.${baseName}";
          irc = "irc.${baseName}";
          mail = "noahmasur.com";
          mathesar = "mathesar.${baseName}";
          metrics = "metrics.${baseName}";
          minecraft = "minecraft.${baseName}";
          n8n = "n8n.${baseName}";
          navidrome = "music.${baseName}";
          notifications = "ntfy.${baseName}";
          paperless = "paper.${baseName}";
          photos = "photos.${baseName}";
          postgresql = "pg.${baseName}";
          prometheus = "prom.${baseName}";
          recipes = "cooking.${baseName}";
          secrets = "vault.${baseName}";
          smtp = "smtp.purelymail.com";
          status = "status.${baseName}";
          stream = "stream.${baseName}";
          transmission = "transmission.${baseName}";
        };

    in
    rec {

      lib = import ./lib inputs;
      flattenAttrset = attrs: builtins.foldl' lib.mergeAttrs { } (builtins.attrValues attrs);

      nixosConfigurations = flattenAttrset (
        builtins.mapAttrs (
          system: hosts:
          builtins.mapAttrs (
            name: module:
            lib.buildNixos {
              inherit system module;
              specialArgs = { inherit hostnames; };
            }
          ) hosts
        ) lib.linuxHosts
      );

      darwinConfigurations = flattenAttrset (
        builtins.mapAttrs (
          system: hosts:
          builtins.mapAttrs (
            name: module:
            lib.buildDarwin {
              inherit system module;
              specialArgs = { inherit hostnames; };
            }
          ) hosts
        ) lib.darwinHosts
      );

      homeModules = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module: (builtins.head (lib.attrsToList module.home-manager.users)).value
        ) hosts
      ) lib.hosts;

      homeConfigurations = flattenAttrset (
        builtins.mapAttrs (
          system: hosts:
          builtins.mapAttrs (
            name: module:
            lib.buildHome {
              inherit system module;
              specialArgs = { inherit hostnames; };
            }
          ) hosts
        ) homeModules
      );

      # Disk formatting, only used once
      diskoConfigurations = {
        root = import ./hosts/x86_64-linux/swan/root.nix;
      };

      generators = builtins.mapAttrs (
        # x86_64-linux = { arrow = ...; swan = ...; }
        system: hosts:
        (lib.concatMapAttrs (name: module: {
          "${name}-aws" = lib.generateImage {
            inherit system module;
            format = "amazon";
            specialArgs = { inherit hostnames; };
          };
          "${name}-iso" = lib.generateImage {
            inherit system module;
            format = "iso";
            specialArgs = { inherit hostnames; };
          };
          "${name}-qcow" = lib.generateImage {
            inherit system module;
            format = "qcow-efi";
            specialArgs = { inherit hostnames; };
            # extraModules = [ "${nixpkgs}/nixos/modules/virtualisation/oci-image.nix" ];
          };
        }) hosts)
      ) lib.linuxHosts # x86_64-linux = { arrow = ...; swan = ...; }
      ;

      # packages =
      #   lib.forSystems lib.linuxSystems (
      #     system: generateImagesForHosts system // lib.pkgsBySystem.${system}.nmasur
      #   )
      #   // lib.forSystems lib.darwinSystems (system: lib.pkgsBySystem.${system}.nmasur);

      packages = lib.forAllSystems (
        system:
        # Share the custom packages that I have placed under the nmasur namespace
        lib.pkgsBySystem.${system}.nmasur
        //
          # Share generated images for each relevant host
          (if (lib.hasInfix "linux" system) then generators.${system} else { })

        # //
        #   # Oracle
        #   {
        #     flame-oci = nixosConfigurations.flame.config.system.build.OCIImage;
        #   }
      );

      # Development environments
      devShells = lib.forAllSystems (system: {
        default = lib.pkgsBySystem.${system}.nmasur.dotfiles-devshell;
      });

      # checks = lib.forAllSystems (
      #   system:
      #   let
      #     pkgs = import nixpkgs {
      #       inherit system;
      #       overlays = lib.overlays;
      #     };
      #   in
      #   {
      #     neovim =
      #       pkgs.runCommand "neovim-check-health" { buildInputs = [ inputs.self.packages.${system}.neovim ]; }
      #         ''
      #           mkdir -p $out
      #           export HOME=$TMPDIR
      #           nvim -c "checkhealth" -c "write $out/health.log" -c "quitall"

      #           # Check for errors inside the health log
      #           if $(grep "ERROR" $out/health.log); then
      #             cat $out/health.log
      #             exit 1
      #           fi
      #         '';
      #   }
      # );

      formatter = lib.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            inherit (lib) overlays;
          };
        in
        pkgs.nixfmt
      );

      # Templates for starting other projects quickly
      templates = (import ./templates { inherit lib; });
    };
}
