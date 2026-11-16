# Caddy with Cloudflare DNS

{
  pkgs,
  ...
}:

(pkgs.caddy.withPlugins {
  plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
  hash = "sha256-HuVBmiT3kD6RrDejQ6SnjCN8f7pFdZlGtZFbEf47bks=";
}).overrideAttrs
  {
    postConfigure = ''
      rm -f cmd/x509rootsfallback.go caddy/cmd/x509rootsfallback.go vendor/github.com/caddyserver/caddy/v2/cmd/x509rootsfallback.go
    '';
  }
