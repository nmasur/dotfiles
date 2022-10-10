{ config, pkgs, lib, ... }: {

  options.networking.wireguard = {

    encryptedPrivateKey = lib.mkOption {
      type = lib.types.path;
      description = "Nix path to age-encrypted client private key";
      default = ../../private/wireguard.age;
    };

  };

  config = {

    networking.wireguard = {
      enable = true;
      interfaces = {
        wg0 = {

          # Establishes identity of this machine
          generatePrivateKeyFile = false;
          privateKeyFile = "/private/wireguard/wg0";

          # Move to network namespace for isolating programs
          interfaceNamespace = "wg";

        };
      };
    };

    # Create namespace for Wireguard
    # This allows us to isolate specific programs to Wireguard
    systemd.services."netns@" = {
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
    systemd.services.wireguard-private-key = {
      wantedBy = [ "wireguard-wg0.service" ];
      requiredBy = [ "wireguard-wg0.service" ];
      before = [ "wireguard-wg0.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = let
        encryptedPrivateKey = config.networking.wireguard.encryptedPrivateKey;
        privateKeyFile =
          config.networking.wireguard.interfaces.wg0.privateKeyFile;
      in ''
        mkdir --parents --mode 0755 ${builtins.dirOf privateKeyFile}
        if [ ! -f "${privateKeyFile}" ]; then
          ${pkgs.age}/bin/age --decrypt \
            --identity ${config.identityFile} \
            --output ${privateKeyFile} \
            ${builtins.toString encryptedPrivateKey}
          chmod 0700 ${privateKeyFile}
        fi
      '';
    };

  };

}
