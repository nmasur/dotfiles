{
  description = "My system";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for specific stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # Used for caddy plugins
    nixpkgs-caddy.url = "github:jpds/nixpkgs/caddy-external-plugins";

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

    # Used for AMD CPU microcode
    ucodenix.url = "github:e-tho/ucodenix";

    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";

    # Use official Firefox binary for macOS
    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
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

    # Wallpapers
    wallpapers = {
      url = "gitlab:exorcist365/wallpapers";
      flake = false;
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

    # Neovim plugins
    base16-nvim-src = {
      url = "github:RRethy/base16-nvim";
      flake = false;
    };
    nvim-lspconfig-src = {
      # https://github.com/neovim/nvim-lspconfig/tags
      url = "github:neovim/nvim-lspconfig/v0.1.8";
      flake = false;
    };
    cmp-nvim-lsp-src = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    baleia-nvim-src = {
      # https://github.com/m00qek/baleia.nvim/tags
      url = "github:m00qek/baleia.nvim";
      flake = false;
    };
    nvim-treesitter-src = {
      # https://github.com/nvim-treesitter/nvim-treesitter/tags
      url = "github:nvim-treesitter/nvim-treesitter/v0.9.2";
      flake = false;
    };
    telescope-nvim-src = {
      # https://github.com/nvim-telescope/telescope.nvim/releases
      url = "github:nvim-telescope/telescope.nvim/0.1.8";
      flake = false;
    };
    telescope-project-nvim-src = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    toggleterm-nvim-src = {
      # https://github.com/akinsho/toggleterm.nvim/tags
      url = "github:akinsho/toggleterm.nvim/v2.12.0";
      flake = false;
    };
    bufferline-nvim-src = {
      # https://github.com/akinsho/bufferline.nvim/releases
      url = "github:akinsho/bufferline.nvim/v4.6.1";
      flake = false;
    };
    nvim-tree-lua-src = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };
    hmts-nvim-src = {
      url = "github:calops/hmts.nvim";
      flake = false;
    };
    fidget-nvim-src = {
      # https://github.com/j-hui/fidget.nvim/tags
      url = "github:j-hui/fidget.nvim/v1.4.5";
      flake = false;
    };
    nvim-lint-src = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    tiny-inline-diagnostic-nvim-src = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    snipe-nvim-src = {
      url = "github:leath-dub/snipe.nvim";
      flake = false;
    };

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

    # Ren and rep - CLI find and replace
    rep = {
      url = "github:robenkleene/rep-grep";
      flake = false;
    };
    ren = {
      url = "github:robenkleene/ren-find";
      flake = false;
    };

    gh-collaborators = {
      url = "github:katiem0/gh-collaborators";
      flake = false;
    };

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
          mail.server = "noahmasur.com";
          mail.imapHost = "imap.purelymail.com";
          mail.smtpHost = "smtp.purelymail.com";
          dotfilesRepo = "https://github.com/nmasur/dotfiles";
          hostnames = {
            audiobooks = "read.${baseName}";
            files = "files.${baseName}";
            git = "git.${baseName}";
            influxdb = "influxdb.${baseName}";
            irc = "irc.${baseName}";
            metrics = "metrics.${baseName}";
            minecraft = "minecraft.${baseName}";
            n8n = "n8n.${baseName}";
            notifications = "ntfy.${baseName}";
            prometheus = "prom.${baseName}";
            paperless = "paper.${baseName}";
            secrets = "vault.${baseName}";
            stream = "stream.${baseName}";
            content = "cloud.${baseName}";
            books = "books.${baseName}";
            download = "download.${baseName}";
            status = "status.${baseName}";
            transmission = "transmission.${baseName}";
          };
        };

      # Common overlays to always use
      overlays = [
        inputs.nur.overlay
        inputs.nix2vim.overlay
        (import ./overlays/neovim-plugins.nix inputs)
        (import ./overlays/disko.nix inputs)
        (import ./overlays/tree-sitter.nix inputs)
        (import ./overlays/mpv-scripts.nix inputs)
        (import ./overlays/nextcloud-apps.nix inputs)
        (import ./overlays/betterlockscreen.nix)
        (import ./overlays/gh-collaborators.nix inputs)
        (import ./overlays/ren-rep.nix inputs)
      ];

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    rec {

      # Contains my full system builds, including home-manager
      # nixos-rebuild switch --flake .#tempest
      nixosConfigurations = {
        arrow = import ./hosts/arrow { inherit inputs globals overlays; };
        tempest = import ./hosts/tempest { inherit inputs globals overlays; };
        hydra = import ./hosts/hydra { inherit inputs globals overlays; };
        flame = import ./hosts/flame { inherit inputs globals overlays; };
        swan = import ./hosts/swan { inherit inputs globals overlays; };
      };

      # Contains my full Mac system builds, including home-manager
      # darwin-rebuild switch --flake .#lookingglass
      darwinConfigurations = {
        lookingglass = import ./hosts/lookingglass { inherit inputs globals overlays; };
      };

      # For quickly applying home-manager settings with:
      # home-manager switch --flake .#tempest
      homeConfigurations = {
        tempest = nixosConfigurations.tempest.config.home-manager.users.${globals.user}.home;
        lookingglass = darwinConfigurations.lookingglass.config.home-manager.users."Noah.Masur".home;
      };

      # Disk formatting, only used once
      diskoConfigurations = {
        root = import ./disks/root.nix;
      };

      packages =
        let
          staff =
            system:
            import ./hosts/staff {
              inherit
                inputs
                globals
                overlays
                system
                ;
            };
          neovim =
            system:
            let
              pkgs = import nixpkgs { inherit system overlays; };
            in
            import ./modules/common/neovim/package {
              inherit pkgs;
              colors = (import ./colorscheme/gruvbox-dark).dark;
            };
        in
        {
          x86_64-linux.staff = staff "x86_64-linux";
          x86_64-linux.arrow = inputs.nixos-generators.nixosGenerate rec {
            system = "x86_64-linux";
            format = "iso";
            specialArgs = {
              pkgs-stable = import inputs.nixpkgs-stable { inherit system; };
              pkgs-caddy = import inputs.nixpkgs-caddy { inherit system; };
            };
            modules = import ./hosts/arrow/modules.nix { inherit inputs globals overlays; };
          };
          x86_64-linux.arrow-aws = inputs.nixos-generators.nixosGenerate rec {
            system = "x86_64-linux";
            format = "amazon";
            specialArgs = {
              pkgs-stable = import inputs.nixpkgs-stable { inherit system; };
              pkgs-caddy = import inputs.nixpkgs-caddy { inherit system; };
            };
            modules = import ./hosts/arrow/modules.nix { inherit inputs globals overlays; } ++ [
              (
                { ... }:
                {
                  boot.kernelPackages = inputs.nixpkgs.legacyPackages.x86_64-linux.linuxKernel.packages.linux_6_6;
                  amazonImage.sizeMB = 16 * 1024;
                  permitRootLogin = "prohibit-password";
                  boot.loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
                  boot.loader.efi.canTouchEfiVariables = inputs.nixpkgs.lib.mkForce false;
                  services.amazon-ssm-agent.enable = true;
                  users.users.ssm-user.extraGroups = [ "wheel" ];
                }
              )
            ];
          };

          # Package Neovim config into standalone package
          x86_64-linux.neovim = neovim "x86_64-linux";
          x86_64-darwin.neovim = neovim "x86_64-darwin";
          aarch64-linux.neovim = neovim "aarch64-linux";
          aarch64-darwin.neovim = neovim "aarch64-darwin";
        };

      # Programs that can be run by calling this flake
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system overlays; };
        in
        import ./apps { inherit pkgs; }
      );

      # Development environments
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system overlays; };
        in
        {

          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              stylua
              nixfmt-rfc-style
              shfmt
              shellcheck
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system overlays; };
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

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system overlays; };
        in
        pkgs.nixfmt-rfc-style
      );

      # Templates for starting other projects quickly
      templates = rec {
        default = basic;
        basic = {
          path = ./templates/basic;
          description = "Basic program template";
        };
        poetry = {
          path = ./templates/poetry;
          description = "Poetry template";
        };
        python = {
          path = ./templates/python;
          description = "Legacy Python template";
        };
        haskell = {
          path = ./templates/haskell;
          description = "Haskell template";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust template";
        };
      };
    };
}
