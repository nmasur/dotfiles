# Fix: bash highlighting doesn't work as of this commit:
# https://github.com/NixOS/nixpkgs/commit/49cce41b7c5f6b88570a482355d9655ca19c1029

_final: prev: {
  tree-sitter-grammars = prev.tree-sitter-grammars // {
    tree-sitter-bash = prev.tree-sitter-grammars.tree-sitter-bash.overrideAttrs
      (old: {
        src = prev.fetchFromGitHub {
          owner = "tree-sitter";
          repo = "tree-sitter-bash";
          rev = "493646764e7ad61ce63ce3b8c59ebeb37f71b841";
          sha256 = "sha256-gl5F3IeZa2VqyH/qFj8ey2pRbGq4X8DL5wiyvRrH56U=";
        };
      });
  };
}
