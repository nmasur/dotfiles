{ pkgs, fetchFromGitHub }:

pkgs.tree-sitter.buildGrammar {
  language = "vimdoc";
  version = "3.0.0";
  src = fetchFromGitHub {
    owner = "neovim";
    repo = "tree-sitter-vimdoc";
    rev = "d2e4b5c172a109966c2ce0378f73df6cede39400";
    sha256 = "sha256-Vrl4/cZL+TWlUMEeWZoHCAWhvlefcl3ajGcwyTNKOhI=";
  };
}
