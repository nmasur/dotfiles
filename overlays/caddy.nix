# Adds the Cloudflare DNS validation module

inputs: _final: prev:

let

  plugins = [ "github.com/caddy-dns/cloudflare" ];
  goImports =
    prev.lib.flip prev.lib.concatMapStrings plugins (pkg: "   _ \"${pkg}\"\n");
  goGets = prev.lib.flip prev.lib.concatMapStrings plugins
    (pkg: "go get ${pkg}\n      ");
  main = ''
    package main
    import (
    	caddycmd "github.com/caddyserver/caddy/v2/cmd"
    	_ "github.com/caddyserver/caddy/v2/modules/standard"
    ${goImports}
    )
    func main() {
    	caddycmd.Main()
    }
  '';

in {
  caddy-cloudflare = prev.buildGo120Module {
    pname = "caddy-cloudflare";
    version = prev.caddy.version;
    runVend = true;

    subPackages = [ "cmd/caddy" ];

    src = prev.caddy.src;

    vendorSha256 = "sha256:mwIsWJYKuEZpOU38qZOG1LEh4QpK4EO0/8l4UGsroU8=";

    overrideModAttrs = (_: {
      preBuild = ''
        echo '${main}' > cmd/caddy/main.go
        ${goGets}
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

    meta = with prev.lib; {
      homepage = "https://caddyserver.com";
      description =
        "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
      license = licenses.asl20;
      maintainers = with maintainers; [ Br1ght0ne techknowlogick ];
    };
  };
}
