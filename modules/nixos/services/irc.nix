{ config, ... }: {

  config = {

    services.thelounge = {
      public = false;
      port = 9000;
      extraConfig = {
        reverseProxy = true;
        maxHistory = 10000;
      };
    };

    # Adding new users:
    # nix shell nixpkgs#thelounge
    # sudo su - thelounge -s /bin/sh -c "thelounge add myuser"

    # Allow web traffic to Caddy
    caddy.routes = [{
      match = [{ host = [ config.hostnames.irc ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{
          dial =
            "localhost:${builtins.toString config.services.thelounge.port}";
        }];
      }];
    }];

  };

}
