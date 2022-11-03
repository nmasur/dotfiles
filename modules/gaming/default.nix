{ config, ... }: {

  config = {
    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
}
