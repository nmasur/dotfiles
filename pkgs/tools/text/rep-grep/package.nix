{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "rep-grep";
  version = "0.0.7";
  src = pkgs.fetchFromGitHub {
    owner = "robenkleene";
    repo = "rep-grep";
    rev = "2a24f95170aa14b5182b2287125664a62f8688ef";
    sha256 = "sha256-gBxrbGCy6JEHnmgJmcm8sgtEvCAqra8/gPGsfCEfLqg=";
  };
  cargoHash = "sha256-t4tfQaFq4EV4ZWeU+IestSFiSAIeVQslTZhLbpKVoO4=";
}
