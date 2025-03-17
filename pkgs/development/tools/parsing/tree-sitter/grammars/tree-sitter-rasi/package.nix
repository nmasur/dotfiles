{ pkgs, fetchFromGitHub }:

pkgs.tree-sitter.buildGrammar {
  language = "rasi";
  version = "0.1.2";
  src = fetchFromGitHub {
    owner = "Fymyte";
    repo = "tree-sitter-rasi";
    rev = "6c9bbcfdf5f0f553d9ebc01750a3aa247a37b8aa";
    sha256 = "sha256-sPrIVgGGaBaXeqHNxjcdJ/S2FvxyV6rD9UPKU/tpspw=";
  };
}
