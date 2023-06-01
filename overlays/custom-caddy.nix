{ lib, buildGo118Module, fetchFromGitHub, plugins ? [ ] }:
let
  imports = lib.flip lib.concatMapStrings plugins (pkg: "   _ \"${pkg}\"\n");
  main = ''
    package main
    import (
    	caddycmd "github.com/caddyserver/caddy/v2/cmd"
    	_ "github.com/caddyserver/caddy/v2/modules/standard"
    ${imports}
    )
    func main() {
    	caddycmd.Main()
    }
  '';
in buildGo118Module rec {
  pname = "caddy";
  version = "2.6.4";
  runVend = true;

  subPackages = [ "cmd/caddy" ];

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v${version}";
    sha256 = "sha256:3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  };

  vendorSha256 = "sha256:CrHqJcJ0knX+txQ5qvzW4JrU8vfi3FO3M/xtislIC1M=";

  overrideModAttrs = (_: {
    preBuild = ''
      echo '${main}' > cmd/caddy/main.go
      go get github.com/caddy-dns/cloudflare
    '';
    postInstall = "cp go.sum go.mod $out/ && ls $out/";
  });

  postPatch = ''
    echo '${main}' > cmd/caddy/main.go
    cat cmd/caddy/main.go
  '';

  postConfigure = ''
    cp vendor/go.sum ./
    cp vendor/go.mod ./
  '';

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ Br1ght0ne techknowlogick ];
  };
}
