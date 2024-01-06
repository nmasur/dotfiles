{
  description = "My system";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for MacOS system config
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for Windows Subsystem for Linux compatibility
    wsl.url = "github:nix-community/NixOS-WSL";

    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Use system packages list for their inputs
    };

    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";

    # Use official Firefox binary for macOS
    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # Nix language server
    nil = {
      url = "github:oxalica/nil/2023-08-09";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins
    nvim-lspconfig-src = {
      # https://github.com/neovim/nvim-lspconfig/tags
      url = "github:neovim/nvim-lspconfig/v0.1.6";
      flake = false;
    };
    cmp-nvim-lsp-src = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    null-ls-nvim-src = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    baleia-nvim-src = {
      # https://github.com/m00qek/baleia.nvim/tags
      url = "github:m00qek/baleia.nvim";
      flake = false;
    };
    Comment-nvim-src = {
      url = "github:numToStr/Comment.nvim/v0.8.0";
      flake = false;
    };
    nvim-treesitter-src = {
      # https://github.com/nvim-treesitter/nvim-treesitter/tags
      url = "github:nvim-treesitter/nvim-treesitter/master";
      flake = false;
    };
    telescope-nvim-src = {
      url = "github:nvim-telescope/telescope.nvim/0.1.4";
      flake = false;
    };
    telescope-project-nvim-src = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    toggleterm-nvim-src = {
      url = "github:akinsho/toggleterm.nvim/v2.8.0";
      flake = false;
    };
    bufferline-nvim-src = {
      url = "github:akinsho/bufferline.nvim/v4.4.0";
      flake = false;
    };
    nvim-tree-lua-src = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };
    vscode-terraform-snippets = {
      url = "github:run-at-scale/vscode-terraform-doc-snippets";
      flake = false;
    };
    hmts-nvim-src = {
      url = "github:calops/hmts.nvim";
      flake = false;
    };
    fidget-nvim-src = {
      # https://github.com/j-hui/fidget.nvim/tags
      url = "github:j-hui/fidget.nvim/v1.1.0";
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

    # MPV Scripts
    zenyd-mpv-scripts = {
      url = "github:zenyd/mpv-scripts";
      flake = false;
    };

    # Age encryption (pin because of failed builds)
    age = {
      url = "github:FiloSottile/age/v1.1.1";
      flake = false;
    };

    # GE version of Proton for game compatibility
    # Alternatively, could consider using https://github.com/fufexan/nix-gaming
    proton-ge = {
      # https://github.com/GloriousEggroll/proton-ge-custom/releases
      url =
        "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-25/GE-Proton8-25.tar.gz";
      flake = false;
    };

    # Firefox addon from outside the extension store
    bypass-paywalls-clean = {
      # https://gitlab.com/magnolia1234/bpc-uploads/-/commits/master/?ref_type=HEADS
      url = "gitlab:magnolia1234/bpc-uploads";
      flake = false;
    };

    # Nextcloud Apps
    nextcloud-news = {
      # https://github.com/nextcloud/news/releases
      url =
        "https://github.com/nextcloud/news/releases/download/25.0.0-alpha3/news.tar.gz";
      flake = false;
    };
    nextcloud-external = {
      # https://github.com/nextcloud-releases/external/releases
      url =
        "https://github.com/nextcloud-releases/external/releases/download/v5.3.1/external-v5.3.1.tar.gz";
      flake = false;
    };
    nextcloud-cookbook = {
      # https://github.com/christianlupus-nextcloud/cookbook-releases/releases/
      url =
        "https://github.com/christianlupus-nextcloud/cookbook-releases/releases/download/v0.11.0/cookbook-0.11.0.tar.gz";
      flake = false;
    };

  };

  outputs = { nixpkgs, ... }@inputs:

    let

      # Global configuration for my systems
      globals = let baseName = "masu.rs";
      in rec {
        user = "noah";
        fullName = "Noah Masur";
        gitName = fullName;
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mail.server = "noahmasur.com";
        mail.imapHost = "imap.purelymail.com";
        mail.smtpHost = "smtp.purelymail.com";
        dotfilesRepo = "https://github.com/nmasur/dotfiles";
        hostnames = {
          git = "git.${baseName}";
          influxdb = "influxdb.${baseName}";
          metrics = "metrics.${baseName}";
          prometheus = "prom.${baseName}";
          paperless = "paper.${baseName}";
          secrets = "vault.${baseName}";
          stream = "stream.${baseName}";
          content = "cloud.${baseName}";
          books = "books.${baseName}";
          download = "download.${baseName}";
        };
      };

      # Common overlays to always use
      overlays = [
        inputs.nur.overlay
        inputs.nix2vim.overlay
        (import ./overlays/neovim-plugins.nix inputs)
        (import ./overlays/calibre-web.nix)
        (import ./overlays/disko.nix inputs)
        (import ./overlays/tree-sitter.nix inputs)
        (import ./overlays/caddy.nix inputs)
        (import ./overlays/mpv-scripts.nix inputs)
        (import ./overlays/nextcloud-apps.nix inputs)
        (import ./overlays/betterlockscreen.nix)
        (import ./overlays/age.nix inputs)
        (import ./overlays/proton-ge.nix inputs)
        (import ./overlays/gh-collaborators.nix)
        (import ./overlays/bypass-paywalls-clean.nix inputs)
        (import ./overlays/terraform.nix)
      ];

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in rec {

      # Contains my full system builds, including home-manager
      # nixos-rebuild switch --flake .#tempest
      nixosConfigurations = {
        tempest = import ./hosts/tempest { inherit inputs globals overlays; };
        hydra = import ./hosts/hydra { inherit inputs globals overlays; };
        flame = import ./hosts/flame { inherit inputs globals overlays; };
        swan = import ./hosts/swan { inherit inputs globals overlays; };
      };

      # Contains my full Mac system builds, including home-manager
      # darwin-rebuild switch --flake .#lookingglass
      darwinConfigurations = {
        lookingglass =
          import ./hosts/lookingglass { inherit inputs globals overlays; };
      };

      # For quickly applying home-manager settings with:
      # home-manager switch --flake .#tempest
      homeConfigurations = {
        tempest =
          nixosConfigurations.tempest.config.home-manager.users.${globals.user}.home;
        lookingglass =
          darwinConfigurations.lookingglass.config.home-manager.users."Noah.Masur".home;
      };

      # Disk formatting, only used once
      diskoConfigurations = { root = import ./disks/root.nix; };

      packages = let
        aws = system:
          import ./hosts/aws { inherit inputs globals overlays system; };
        staff = system:
          import ./hosts/staff { inherit inputs globals overlays system; };
        neovim = system:
          let pkgs = import nixpkgs { inherit system overlays; };
          in import ./modules/common/neovim/package {
            inherit pkgs;
            colors = (import ./colorscheme/gruvbox-dark).dark;
          };
      in {
        x86_64-linux.aws = aws "x86_64-linux";
        x86_64-linux.staff = staff "x86_64-linux";

        # Package Neovim config into standalone package
        x86_64-linux.neovim = neovim "x86_64-linux";
        x86_64-darwin.neovim = neovim "x86_64-darwin";
        aarch64-linux.neovim = neovim "aarch64-linux";
        aarch64-darwin.neovim = neovim "aarch64-darwin";
      };

      # Programs that can be run by calling this flake
      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in import ./apps { inherit pkgs; });

      # Development environments
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {

          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git stylua nixfmt shfmt shellcheck ];
          };

        });

      checks = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          neovim = pkgs.runCommand "neovim-check-health" {
            buildInputs = [ inputs.self.packages.${system}.neovim ];
          } ''
            mkdir -p $out
            export HOME=$TMPDIR
            nvim -c "checkhealth" -c "write $out/health.log" -c "quitall"

            # Check for errors inside the health log
            if $(grep "ERROR" $out/health.log); then
              cat $out/health.log
              exit 1
            fi
          '';
        });

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
      };

    };
}
