{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.vm;
in

{

  options.nmasur.presets.vm.enable = lib.mkEnableOption "VM-specific settings for testing";

  config = lib.mkIf cfg.enable {

    # Settings for testing in a VM
    virtualisation.vmVariant = {
      home-manager.users."noah".programs.nix-index.enable = false;
      nmasur.presets.services.openssh.enable = true;
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };

  };
}
