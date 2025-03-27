{ pkgs, fetchFromGitHub }:

pkgs.tree-sitter.buildGrammar {
  language = "ini";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "justinmk";
    repo = "tree-sitter-ini";
    rev = "32b31863f222bf22eb43b07d4e9be8017e36fb31";
    sha256 = "sha256-kWCaOIC81GP5EHCqzPZP9EUgYy39CZ6/8TVS6soB6Wo=";
  };
}
