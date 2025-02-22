# Clipboard over SSH

{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule {
  pname = "osc";
  version = "v0.4.6";
  src = fetchFromGitHub {
    owner = "theimpostor";
    repo = "osc";
    rev = "4af7c8e54ecc499097121909f02ecb42a8a60d24";
    sha256 = lib.fakeSha256;
  };

  vendorHash = "sha256-POtQWIjPObsfa3YZ1dLZgedZFUcc4HeTWjU20AucoKc=";

  ldflags = [
    "-s"
    "-w"
  ];
}
