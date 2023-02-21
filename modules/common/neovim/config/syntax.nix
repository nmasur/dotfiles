{ pkgs, ... }: {

  plugins = [
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins:
      with pkgs.tree-sitter-grammars; [
        tree-sitter-hcl
        tree-sitter-python
        tree-sitter-lua
        tree-sitter-nix
        tree-sitter-fish
        tree-sitter-toml
        tree-sitter-yaml
        tree-sitter-json
      ]))
    pkgs.vimPlugins.vim-matchup # Better % jumping in languages
    pkgs.vimPlugins.nginx-vim
    pkgs.vimPlugins.vim-helm
    pkgs.vimPlugins.vim-puppet
  ];

  setup."nvim-treesitter.configs" = {
    highlight = { enable = true; };
    indent = { enable = true; };

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

}
