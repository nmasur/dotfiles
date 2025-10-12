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
    hash = "sha256-AcWko5513hO8I0lvbCLqVbM1eWegAhoM0J0qXoWL/vI=";
  }
