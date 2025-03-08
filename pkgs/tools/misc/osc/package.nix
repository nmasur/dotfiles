# Clipboard over SSH

{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule {
  pname = "osc";
  version = "v0.4.7";
  src = fetchFromGitHub {
    owner = "theimpostor";
    repo = "osc";
    rev = "c8e1e2f42a5d5fb628eaa48e889bde578deb8d33";
    sha256 = "sha256-MfEBbYT99tEtlOMmdl3iq2d07KYsN1tu5tDRFW3676g=";
  };

  vendorHash = "sha256-POtQWIjPObsfa3YZ1dLZgedZFUcc4HeTWjU20AucoKc=";

  ldflags = [
    "-s"
    "-w"
  ];
}
