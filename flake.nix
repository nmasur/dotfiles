{
  description = "My system";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for MacOS system config
    darwin = {
      url = "github:/lnl7/nix-darwin/master";
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
      url = "github:oxalica/nil/2023-04-03";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins
    nvim-lspconfig-src = {
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
    Comment-nvim-src = {
      url = "github:numToStr/Comment.nvim/v0.8.0";
      flake = false;
    };
    nvim-treesitter-src = {
      url = "github:nvim-treesitter/nvim-treesitter/v0.9.0";
      flake = false;
    };
    telescope-nvim-src = {
      url = "github:nvim-telescope/telescope.nvim/0.1.2";
      flake = false;
    };
    telescope-project-nvim-src = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    toggleterm-nvim-src = {
      url = "github:akinsho/toggleterm.nvim/v2.7.0";
      flake = false;
    };
    bufferline-nvim-src = {
      url = "github:akinsho/bufferline.nvim/v4.2.0";
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
        dotfilesRepo = "git@github.com:nmasur/dotfiles";
        hostnames = {
          git = "git.${baseName}";
          metrics = "metrics.${baseName}";
          prometheus = "prom.${baseName}";
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
        (import ./overlays/tree-sitter-bash.nix)
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
