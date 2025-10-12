# Caddy with Cloudflare DNS

{
  pkgs,
  fetchFromGitHub,
  ...
}:

# Maintain a static version so that the plugin hash doesn't keep breaking
(pkgs.caddy.overrideAttrs rec {
  version = "2.10.2";
  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    tag = "v${version}";
    hash = "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=";
  };
}).withPlugins
  {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    hash = "sha256-XwZ0Hkeh2FpQL/fInaSq+/3rCLmQRVvwBM0Y1G1FZNU=";
  }
