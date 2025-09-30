# Caddy with Cloudflare DNS

{
  pkgs,
  ...
}:

# Maintain a static version so that the plugin hash doesn't keep breaking
(pkgs.caddy.override {
  version = "2.10.2";
}).withPlugins
  {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    hash = "sha256-AcWko5513hO8I0lvbCLqVbM1eWegAhoM0J0qXoWL/vI=";
  }
