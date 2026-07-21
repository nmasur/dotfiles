# Caddy with Cloudflare DNS

{
  pkgs,
  ...
}:

pkgs.caddy.withPlugins {
  plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
  hash = "sha256-HuVBmiT3kD6RrDejQ6SnjCN8f7pFdZlGtZFbEf47bks=";
}
