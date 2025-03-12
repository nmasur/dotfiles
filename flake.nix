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

    # # Use official Firefox binary for macOS
    # firefox-darwin = {
    #   url = "github:bandithedoge/nixpkgs-firefox-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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

    # # Wallpapers
    # wallpapers = {
    #   url = "gitlab:exorcist365/wallpapers";
    #   flake = false;
    # };

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

    # # Neovim plugins
    # base16-nvim-src = {
    #   url = "github:RRethy/base16-nvim";
    #   flake = false;
    # };
    # nvim-lspconfig-src = {
    #   # https://github.com/neovim/nvim-lspconfig/tags
    #   url = "github:neovim/nvim-lspconfig/v0.1.8";
    #   flake = false;
    # };
    # cmp-nvim-lsp-src = {
    #   url = "github:hrsh7th/cmp-nvim-lsp";
    #   flake = false;
    # };
    # baleia-nvim-src = {
    #   # https://github.com/m00qek/baleia.nvim/tags
    #   url = "github:m00qek/baleia.nvim";
    #   flake = false;
    # };
    # nvim-treesitter-src = {
    #   # https://github.com/nvim-treesitter/nvim-treesitter/tags
    #   url = "github:nvim-treesitter/nvim-treesitter/v0.9.2";
    #   flake = false;
    # };
    # telescope-nvim-src = {
    #   # https://github.com/nvim-telescope/telescope.nvim/releases
    #   url = "github:nvim-telescope/telescope.nvim/0.1.8";
    #   flake = false;
    # };
    # telescope-project-nvim-src = {
    #   url = "github:nvim-telescope/telescope-project.nvim";
    #   flake = false;
    # };
    # toggleterm-nvim-src = {
    #   # https://github.com/akinsho/toggleterm.nvim/tags
    #   url = "github:akinsho/toggleterm.nvim/v2.12.0";
    #   flake = false;
    # };
    # bufferline-nvim-src = {
    #   # https://github.com/akinsho/bufferline.nvim/releases
    #   url = "github:akinsho/bufferline.nvim/v4.6.1";
    #   flake = false;
    # };
    # nvim-tree-lua-src = {
    #   url = "github:kyazdani42/nvim-tree.lua";
    #   flake = false;
    # };
    # hmts-nvim-src = {
    #   url = "github:calops/hmts.nvim";
    #   flake = false;
    # };
    # fidget-nvim-src = {
    #   # https://github.com/j-hui/fidget.nvim/tags
    #   url = "github:j-hui/fidget.nvim/v1.4.5";
    #   flake = false;
    # };
    # nvim-lint-src = {
    #   url = "github:mfussenegger/nvim-lint";
    #   flake = false;
    # };
    # tiny-inline-diagnostic-nvim-src = {
    #   url = "github:rachartier/tiny-inline-diagnostic.nvim";
    #   flake = false;
    # };
    # snipe-nvim-src = {
    #   url = "github:leath-dub/snipe.nvim";
    #   flake = false;
    # };

    # Tree-Sitter Grammars
    tree-sitter-bash = {
      url = "github:tree-sitter/tree-sitter-bash/master";
      flake = false;
    };
    tree-sitter-python = {
      url = "github:tree-sitter/tree-sitter-python/master";
      flake = false;
    };
    tree-sitter-lua = {
      url = "github:MunifTanjim/tree-sitter-lua/main";
      flake = false;
    };
    tree-sitter-ini = {
      url = "github:justinmk/tree-sitter-ini";
      flake = false;
    };
    tree-sitter-puppet = {
      url = "github:amaanq/tree-sitter-puppet";
      flake = false;
    };
    tree-sitter-rasi = {
      url = "github:Fymyte/tree-sitter-rasi";
      flake = false;
    };
    tree-sitter-vimdoc = {
      url = "github:neovim/tree-sitter-vimdoc";
      flake = false;
    };

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

      darwinConfigurations = builtins.mapAttrs (
        system: hosts:
        builtins.mapAttrs (
          name: module:
          lib.buildDarwin {
            inherit system module;
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

      # packages =
      #   let
      #     staff =
      #       system:
      #       import ./hosts/staff {
      #         inherit
      #           inputs
      #           globals
      #           overlays
      #           system
      #           ;
      #       };
      #     neovim =
      #       system:
      #       let
      #         pkgs = import nixpkgs { inherit system overlays; };
      #       in
      #       import ./modules/common/neovim/package {
      #         inherit pkgs;
      #         colors = (import ./colorscheme/gruvbox-dark).dark;
      #       };
      #   in
      #   {
      #     x86_64-linux.staff = staff "x86_64-linux";
      #     x86_64-linux.arrow = inputs.nixos-generators.nixosGenerate rec {
      #       system = "x86_64-linux";
      #       format = "iso";
      #       modules = import ./hosts/arrow/modules.nix { inherit inputs globals overlays; };
      #     };
      #     x86_64-linux.arrow-aws = inputs.nixos-generators.nixosGenerate rec {
      #       system = "x86_64-linux";
      #       format = "amazon";
      #       modules = import ./hosts/arrow/modules.nix { inherit inputs globals overlays; } ++ [
      #         (
      #           { ... }:
      #           {
      #             boot.kernelPackages = inputs.nixpkgs.legacyPackages.x86_64-linux.linuxKernel.packages.linux_6_6;
      #             amazonImage.sizeMB = 16 * 1024;
      #             permitRootLogin = "prohibit-password";
      #             boot.loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
      #             boot.loader.efi.canTouchEfiVariables = inputs.nixpkgs.lib.mkForce false;
      #             services.amazon-ssm-agent.enable = true;
      #             users.users.ssm-user.extraGroups = [ "wheel" ];
      #           }
      #         )
      #       ];
      #     };

      #   # Package Neovim config into standalone package
      #   x86_64-linux.neovim = neovim "x86_64-linux";
      #   x86_64-darwin.neovim = neovim "x86_64-darwin";
      #   aarch64-linux.neovim = neovim "aarch64-linux";
      #   aarch64-darwin.neovim = neovim "aarch64-darwin";
      # };

      # Get the custom packages that I have placed under the nmasur namespace
      packages = lib.forAllSystems (system: lib.pkgsBySystem.${system}.nmasur);

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
