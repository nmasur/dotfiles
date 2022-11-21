{ ... }: {

  services.n8n = {
    enable = true;
    settings = {
      n8n = {
        listenAddress = "127.0.0.1";
        port = 5678;
      };
    };
  };

  caddyRoutes = [{
    match = [{ host = [ config.n8nServer ]; }];
    handle = [{
      handler = "reverse_proxy";
      upstreams = [{ dial = "localhost:5678"; }];
    }];
  }];

}
