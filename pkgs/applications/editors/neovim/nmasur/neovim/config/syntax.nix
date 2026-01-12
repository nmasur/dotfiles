{ pkgs, lib, ... }:
{

  plugins = [
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins: [
      pkgs.nmasur.tree-sitter-ini
      pkgs.nmasur.tree-sitter-puppet
      pkgs.nmasur.tree-sitter-rasi
      pkgs.nmasur.tree-sitter-vimdoc
      pkgs.tree-sitter-grammars.tree-sitter-bash
      pkgs.tree-sitter-grammars.tree-sitter-c
      pkgs.tree-sitter-grammars.tree-sitter-fish
      pkgs.tree-sitter-grammars.tree-sitter-hcl
      pkgs.tree-sitter-grammars.tree-sitter-json
      pkgs.tree-sitter-grammars.tree-sitter-lua
      pkgs.tree-sitter-grammars.tree-sitter-markdown
      pkgs.tree-sitter-grammars.tree-sitter-markdown-inline
      pkgs.tree-sitter-grammars.tree-sitter-nix
      pkgs.tree-sitter-grammars.tree-sitter-python
      pkgs.tree-sitter-grammars.tree-sitter-toml
      pkgs.tree-sitter-grammars.tree-sitter-yaml
    ]))
    pkgs.vimPlugins.vim-matchup # Better % jumping in languages
    pkgs.vimPlugins.nginx-vim
    pkgs.vimPlugins.vim-helm
    # pkgs.vimPlugins.hmts-nvim # Tree-sitter injections for home-manager
    (pkgs.vimUtils.buildVimPlugin {
      pname = "nmasur";
      version = "0.1";
      src = ../plugin;
    })
  ];

  setup."nvim-treesitter.configs" = {
    highlight = {
      enable = true;
    };
    indent = {
      enable = true;
    };
    matchup = {
      enable = true;
    }; # Uses vim-matchup

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
