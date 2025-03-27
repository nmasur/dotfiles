{
  pkgs,
  lib,
  config,
  dsl,
  ...
}:
{

  # Terraform optional because non-free
  options.terraform = lib.mkEnableOption "Whether to enable Terraform LSP";
  options.github = lib.mkEnableOption "Whether to enable GitHub features";
  options.kubernetes = lib.mkEnableOption "Whether to enable Kubernetes features";

  config = {
    plugins = [
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.conform-nvim
      pkgs.vimPlugins.fidget-nvim
      pkgs.vimPlugins.nvim-lint
      pkgs.vimPlugins.vim-table-mode
      pkgs.vimPlugins.tiny-inline-diagnostic-nvim
    ];

    setup.fidget = { };
    setup.tiny-inline-diagnostic = { };

    use.lspconfig.lua_ls.setup = dsl.callWith {
      settings = {
        Lua = {
          diagnostics = {
            globals = [
              "vim"
              "hs"
            ];
          };
        };
      };
      capabilities = dsl.rawLua "require('cmp_nvim_lsp').default_capabilities()";
      cmd = [ "${pkgs.lua-language-server}/bin/lua-language-server" ];
    };

    use.lspconfig.nixd.setup = dsl.callWith {
      cmd = [ "${pkgs.nixd}/bin/nixd" ];
      capabilities = dsl.rawLua "require('cmp_nvim_lsp').default_capabilities()";
    };

    use.lspconfig.pyright.setup = dsl.callWith {
      cmd = [
        "${pkgs.pyright}/bin/pyright-langserver"
        "--stdio"
      ];
    };

    use.lspconfig.terraformls.setup = dsl.callWith {
      cmd =
        if config.terraform then
          [
            "${pkgs.terraform-ls}/bin/terraform-ls"
            "serve"
          ]
        else
          [ "echo" ];
    };

    use.lspconfig.rust_analyzer.setup = dsl.callWith {
      cmd = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
      settings = {
        "['rust-analyzer']" = {
          check = {
            command = "clippy";
          };
          files = {
            excludeDirs = [ ".direnv" ];
          };
          cargo = {
            features = "all";
          };
        };
      };
    };

    setup.conform = {
      format_on_save = {
        # These options will be passed to conform.format()
        timeout_ms = 1500;
        lsp_fallback = true;
      };
      formatters_by_ft = {
        lua = [ "stylua" ];
        python = [ "black" ];
        fish = [ "fish_indent" ];
        nix = [ "nixfmt" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        terraform = if config.terraform then [ "terraform_fmt" ] else [ ];
        hcl = [ "hcl" ];
      };
      formatters = {
        lua.command = "${pkgs.stylua}/bin/stylua";
        black.command = "${pkgs.black}/bin/black";
        fish_indent.command = "${pkgs.fish}/bin/fish_indent";
        nixfmt.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        rustfmt.command = "${pkgs.rustfmt}/bin/rustfmt";
        shfmt = {
          command = "${pkgs.shfmt}/bin/shfmt";
          prepend_args = [
            "-i"
            "4"
            "-ci"
          ];
        };
        terraform_fmt.command = if config.terraform then "${pkgs.terraform}/bin/terraform" else "";
        hcl.command = "${pkgs.hclfmt}/bin/hclfmt";
      };
    };

    use.lint = {
      linters_by_ft = dsl.toTable {
        python = [ "ruff" ];
        sh = [ "shellcheck" ];
      };
    };

    vim.api.nvim_create_autocmd = dsl.callWith [
      (dsl.toTable [
        "BufEnter"
        "BufWritePost"
      ])
      (dsl.rawLua "{ callback = function() require('lint').try_lint() end }")
    ];

    lua = ''
      ${builtins.readFile ./lsp.lua}

      local ruff = require('lint').linters.ruff; ruff.cmd = "${pkgs.ruff}/bin/ruff"
      local shellcheck = require('lint').linters.shellcheck; shellcheck.cmd = "${pkgs.shellcheck}/bin/shellcheck"

      -- Prevent infinite log size (change this when debugging)
      vim.lsp.set_log_level("off")

      -- Hide buffer diagnostics (use tiny-inline-diagnostic.nvim instead)
      vim.diagnostic.config({ virtual_text = false })
    '';
  };
}
