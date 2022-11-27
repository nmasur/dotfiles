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

    # Used for user packages
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Use system packages list where available
    };

    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";

    # Use official Firefox binary for macOS
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

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
    nil.url = "github:oxalica/nil";

    # Neovim plugins
    nvim-lspconfig-src = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    cmp-nvim-lsp-src = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-buffer-src = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    plenary-nvim-src = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    null-ls-nvim-src = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    vim-surround-src = {
      url = "github:tpope/vim-surround";
      flake = false;
    };
    vim-repeat-src = {
      url = "github:tpope/vim-repeat";
      flake = false;
    };
    Comment-nvim-src = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    impatient-nvim-src = {
      url = "github:lewis6991/impatient.nvim";
      flake = false;
    };
    nvim-treesitter-src = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    telescope-nvim-src = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    telescope-project-nvim-src = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    toggleterm-nvim-src = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    gitsigns-nvim-src = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    lualine-nvim-src = {
      url = "github:hoob3rt/lualine.nvim";
      flake = false;
    };
    nvim-web-devicons-src = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    bufferline-nvim-src = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    vim-bbye-src = {
      url = "github:moll/vim-bbye";
      flake = false;
    };
    nvim-tree-lua-src = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:

    let

      # Global configuration for my systems
      globals = rec {
        user = "noah";
        fullName = "Noah Masur";
        gitName = fullName;
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mailServer = "noahmasur.com";
        dotfilesRepo = "git@github.com:nmasur/dotfiles";
      };

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in rec {

      nixosConfigurations = {
        desktop = import ./hosts/desktop { inherit inputs globals; };
        wsl = import ./hosts/wsl { inherit inputs globals; };
        oracle = import ./hosts/oracle { inherit inputs globals; };
      };

      darwinConfigurations = {
        macbook = import ./hosts/macbook { inherit inputs globals; };
      };

      # For quickly applying local settings with:
      # home-manager switch --flake .#desktop
      homeConfigurations = {
        desktop =
          nixosConfigurations.desktop.config.home-manager.users.${globals.user}.home;
        macbook =
          darwinConfigurations.macbook.config.home-manager.users."Noah.Masur".home;
      };

      # Package servers into images with a generator
      packages = forAllSystems (system: {

        aws = {
          "${system}" = import ./hosts/aws { inherit inputs globals system; };
        };

        neovim = let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import ./modules/neovim/plugins-overlay.nix inputs)
              inputs.nix2vim.overlay
            ];
          };
        in pkgs.neovimBuilder {
          package = pkgs.neovim-unwrapped;
          imports = [
            ./modules/neovim/plugins/gitsigns.nix
            ./modules/neovim/plugins/misc.nix
            # ({ pkgs, dsl, ... }:
            #   # with dsl; 
            #   {
            #     plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
            #     setup.gitsigns = { };
            #     lua = ''
            #       vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
            #       vim.g.mapleader = " "
            #       vim.g.maplocalleader = " "
            #       local gitsigns = require("gitsigns")
            #       vim.keymap.set("n", "<Leader>gB", gitsigns.blame_line)
            #       vim.keymap.set("n", "<Leader>gp", gitsigns.preview_hunk)
            #       vim.keymap.set("v", "<Leader>gp", gitsigns.preview_hunk)
            #       vim.keymap.set("n", "<Leader>gd", gitsigns.diffthis)
            #       vim.keymap.set("v", "<Leader>gd", gitsigns.diffthis)
            #       vim.keymap.set("n", "<Leader>rgf", gitsigns.reset_buffer)
            #       vim.keymap.set("v", "<Leader>hs", gitsigns.stage_hunk)
            #       vim.keymap.set("v", "<Leader>hr", gitsigns.reset_hunk)
            #       vim.keymap.set("v", "<Leader>hr", gitsigns.reset_hunk)
            #
            #       -- Navigation
            #       vim.keymap.set("n", "]g", function()
            #           if vim.wo.diff then
            #               return "]g"
            #           end
            #           vim.schedule(function()
            #               gitsigns.next_hunk()
            #           end)
            #           return "<Ignore>"
            #       end, { expr = true })
            #
            #       vim.keymap.set("n", "[g", function()
            #           if vim.wo.diff then
            #               return "[g"
            #           end
            #           vim.schedule(function()
            #               gitsigns.prev_hunk()
            #           end)
            #           return "<Ignore>"
            #       end, { expr = true })
            #     '';
            #   })
          ];
        };

      });

      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in import ./apps { inherit pkgs; });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {

          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git stylua nixfmt shfmt shellcheck ];
          };

          # Used for cloud and systems development and administration
          devops = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              terraform
              consul
              vault
              awscli2
              google-cloud-sdk
              ansible
              kubectl
              kubernetes-helm
              kustomize
              fluxcd
            ];
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
