{ pkgs, fetchFromGitHub }:

pkgs.tree-sitter.buildGrammar {
  language = "puppet";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "tree-sitter-grammars";
    repo = "tree-sitter-puppet";
    rev = "15f192929b7d317f5914de2b4accd37b349182a6";
    sha256 = "sha256-bO5g5AdhzpB13yHklpAndUHIX7Rvd7OMjH0Ds2ATA6Q=";
  };
}
