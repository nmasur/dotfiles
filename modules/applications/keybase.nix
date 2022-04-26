{ config, ... }: {
  config = {
    services.keybase.enable = true;
    services.kbfs.enable = true;
  };
}
