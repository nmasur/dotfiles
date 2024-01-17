{ config, ... }: {

  services.postgresql = {
    settings = { };
    identMap = "";
    ensureUsers = [{
      name = config.user;
      ensureClauses = {
        createdb = true;
        createrole = true;
        login = true;
      };
    }];
  };

}
