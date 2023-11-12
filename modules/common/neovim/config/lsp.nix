{ pkgs, lib, config, dsl, ... }: {

  # Terraform optional because non-free
  options.terraform = lib.mkEnableOption "Whether to enable Terraform LSP";
  options.github = lib.mkEnableOption "Whether to enable GitHub features";
  options.kubernetes =
    lib.mkEnableOption "Whether to enable Kubernetes features";

  config =

    let

      terraformFormat = if config.terraform then ''
        require("null-ls").builtins.formatting.terraform_fmt.with({
            command = "${pkgs.terraform}/bin/terraform",
            extra_filetypes = { "hcl" },
        }),
      '' else
        "";

    in {
      plugins = [ pkgs.vimPlugins.nvim-lspconfig pkgs.vimPlugins.null-ls-nvim ];

      use.lspconfig.lua_ls.setup = dsl.callWith {
        settings = { Lua = { diagnostics = { globals = [ "vim" "hs" ]; }; }; };
        capabilities =
          dsl.rawLua "require('cmp_nvim_lsp').default_capabilities()";
        cmd = [ "${pkgs.lua-language-server}/bin/lua-language-server" ];
      };

      use.lspconfig.nil_ls.setup = dsl.callWith {
        cmd = [ "${pkgs.nil}/bin/nil" ];
        capabilities =
          dsl.rawLua "require('cmp_nvim_lsp').default_capabilities()";
      };

      use.lspconfig.pyright.setup = dsl.callWith {
        cmd = [ "${pkgs.pyright}/bin/pyright-langserver" "--stdio" ];
      };

      use.lspconfig.terraformls.setup = dsl.callWith {
        cmd = if config.terraform then [
          "${pkgs.terraform-ls}/bin/terraform-ls"
          "serve"
        ] else
          [ "echo" ];
      };

      use.lspconfig.rust_analyzer.setup = dsl.callWith {
        cmd = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
        settings = {
          "['rust-analyzer']" = { check = { command = "clippy"; }; };
        };
      };

      vim.api.nvim_create_augroup = dsl.callWith [ "LspFormatting" { } ];

      lua = ''
        ${builtins.readFile ./lsp.lua}

        -- Prevent infinite log size (change this when debugging)
        vim.lsp.set_log_level("off")

        require("null-ls").setup({
            sources = {
                require("null-ls").builtins.formatting.stylua.with({ command = "${pkgs.stylua}/bin/stylua" }),
                require("null-ls").builtins.formatting.black.with({ command = "${pkgs.black}/bin/black" }),
                require("null-ls").builtins.diagnostics.ruff.with({ command = "${pkgs.ruff}/bin/ruff" }),
                require("null-ls").builtins.formatting.fish_indent.with({ command = "${pkgs.fish}/bin/fish_indent" }),
                require("null-ls").builtins.formatting.nixfmt.with({ command = "${pkgs.nixfmt}/bin/nixfmt" }),
                require("null-ls").builtins.formatting.rustfmt.with({ command = "${pkgs.rustfmt}/bin/rustfmt" }),
                require("null-ls").builtins.diagnostics.shellcheck.with({ command = "${pkgs.shellcheck}/bin/shellcheck" }),
                require("null-ls").builtins.formatting.shfmt.with({
                    command = "${pkgs.shfmt}/bin/shfmt",
                    extra_args = { "-i", "4", "-ci" },
                }),
                ${terraformFormat}
            },

            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    -- Auto-format on save
                    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                    -- Use internal formatting for bindings like gq.
                    vim.api.nvim_create_autocmd("LspAttach", {
                        callback = function(args)
                            vim.bo[args.buf].formatexpr = nil
                        end,
                    })
                end
            end,
        })
      '';

    };

}
