# Wireguard is a VPN protocol that can be setup to create a mesh network
# between machines on different LANs. This is currently not in use in my setup.

{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.wireguard.enable = lib.mkEnableOption "Wireguard VPN setup.";

  config = lib.mkIf (pkgs.stdenv.isLinux) {

    networking.wireguard = {
      enable = config.wireguard.enable;
      interfaces = {
        wg0 = {

          # Something to use as a default value
          ips = lib.mkDefault [ "127.0.0.1/32" ];

          # Establishes identity of this machine
          generatePrivateKeyFile = false;
          privateKeyFile = config.secrets.wireguard.dest;

          # Move to network namespace for isolating programs
          interfaceNamespace = "wg";
        };
      };
    };

    # Create namespace for Wireguard
    # This allows us to isolate specific programs to Wireguard
    systemd.services."netns@" = {
      enable = config.wireguard.enable;
      description = "%I network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      };
    };

    # Create private key file for wireguard
    secrets.wireguard = lib.mkIf config.wireguard.enable {
      source = ../../../private/wireguard.age;
      dest = "${config.secretsDirectory}/wireguard";
    };
  };
}
