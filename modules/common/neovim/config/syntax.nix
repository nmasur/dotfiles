{ pkgs, lib, config, ... }: {

  plugins = [
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins:
      with pkgs.tree-sitter-grammars;
      [
        tree-sitter-bash
        tree-sitter-c
        tree-sitter-fish
        tree-sitter-ini
        tree-sitter-json
        tree-sitter-lua
        tree-sitter-markdown
        tree-sitter-markdown-inline
        tree-sitter-nix
        tree-sitter-puppet
        tree-sitter-rasi
        tree-sitter-toml
        tree-sitter-vimdoc
        tree-sitter-yaml
      ] ++ (if config.python.enable then [ tree-sitter-python ] else [ ])
      ++ (if config.terraform.enable then [ tree-sitter-hcl ] else [ ])))
    pkgs.vimPlugins.vim-matchup # Better % jumping in languages
    pkgs.vimPlugins.playground # Tree-sitter experimenting
    pkgs.vimPlugins.nginx-vim
    pkgs.baleia-nvim # Clean ANSI from kitty scrollback
    # pkgs.hmts-nvim # Tree-sitter injections for home-manager
    (pkgs.vimUtils.buildVimPlugin {
      pname = "nmasur";
      version = "0.1";
      src = ../plugin;
    })
  ] ++ (if config.kubernetes.enable then [ pkgs.vimPlugins.vim-helm ] else [ ]);

  setup."nvim-treesitter.configs" = {
    highlight = { enable = true; };
    indent = { enable = true; };
    matchup = { enable = true; }; # Uses vim-matchup

    textobjects = {
      select = {
        enable = true;
        lookahead = true; # Jump forward automatically

        keymaps = {
          "['af']" = "@function.outer";
          "['if']" = "@function.inner";
          "['ac']" = "@class.outer";
          "['ic']" = "@class.inner";
          "['al']" = "@loop.outer";
          "['il']" = "@loop.inner";
          "['aa']" = "@call.outer";
          "['ia']" = "@call.inner";
          "['ar']" = "@parameter.outer";
          "['ir']" = "@parameter.inner";
          "['aC']" = "@comment.outer";
          "['iC']" = "@comment.outer";
          "['a/']" = "@comment.outer";
          "['i/']" = "@comment.outer";
          "['a;']" = "@statement.outer";
          "['i;']" = "@statement.outer";
        };
      };
    };
  };

  # Use mkAfter to ensure tree-sitter is already loaded
  lua = lib.mkAfter ''
    -- Use HCL parser with .tf files
    vim.treesitter.language.register('hcl', 'terraform')
  '';

}
