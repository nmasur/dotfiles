{
  config,
  pkgs,
  lib,
  ...
}:

let

  localPort = 25564;
  publicPort = 49732;
  rconPort = 25575;
  rconPassword = "thiscanbeanything";
in
{

  config = lib.mkIf config.services.minecraft-server.enable {

    unfreePackages = [ "minecraft-server" ];

    services.minecraft-server = {
      eula = true;
      declarative = true;
      whitelist = { };
      openFirewall = false;
      serverProperties = {
        server-port = localPort;
        difficulty = "normal";
        gamemode = "survival";
        white-list = false;
        enforce-whitelist = false;
        level-name = "world";
        motd = "Welcome!";
        pvp = true;
        player-idle-timeout = 30;
        generate-structures = true;
        max-players = 20;
        snooper-enabled = false;
        spawn-npcs = true;
        spawn-animals = true;
        spawn-monsters = true;
        allow-nether = true;
        allow-flight = false;
        enable-rcon = true;
        "rcon.port" = rconPort;
        "rcon.password" = rconPassword;
      };
    };

    networking.firewall.allowedTCPPorts = [ publicPort ];

    cloudflare.noProxyDomains = [ config.hostnames.minecraft ];

    ## Automatically start and stop Minecraft server based on player connections

    # Adapted shamelessly from:
    # https://dataswamp.org/~solene/2022-08-20-on-demand-minecraft-with-systemd.html

    # Prevent Minecraft from starting by default
    systemd.services.minecraft-server = {
      wantedBy = pkgs.lib.mkForce [ ];
    };

    # Listen for connections on the public port, to trigger the actual
    # listen-minecraft service.
    systemd.sockets.listen-minecraft = {
      wantedBy = [ "sockets.target" ];
      requires = [ "network.target" ];
      listenStreams = [ "${toString publicPort}" ];
    };

    # Proxy traffic to local port, and trigger hook-minecraft
    systemd.services.listen-minecraft = {
      path = [ pkgs.systemd ];
      requires = [
        "hook-minecraft.service"
        "listen-minecraft.socket"
      ];
      after = [
        "hook-minecraft.service"
        "listen-minecraft.socket"
      ];
      serviceConfig.ExecStart = "${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString localPort}";
    };

    # Start Minecraft if required and wait for it to be available
    # Then unlock the listen-minecraft.service
    systemd.services.hook-minecraft = {
      path = with pkgs; [
        systemd
        libressl
        busybox
      ];

      # Start Minecraft and the auto-shutdown timer
      script = ''
        systemctl start minecraft-server.service
        systemctl start stop-minecraft.timer
      '';

      # Keep checking until the service is available
      postStart = ''
        for i in $(seq 60); do
          if ${pkgs.libressl.nc}/bin/nc -z 127.0.0.1 ${toString localPort} > /dev/null ; then
            exit 0
          fi
          ${pkgs.busybox.out}/bin/sleep 1
        done
        exit 1
      '';
    };

    # Run a player check on a schedule for auto-shutdown
    systemd.timers.stop-minecraft = {
      timerConfig = {
        OnCalendar = "*-*-* *:*:0/20"; # Every 20 seconds
        Unit = "stop-minecraft.service";
      };
    };

    # If no players are connected, then stop services and prepare to resume again
    systemd.services.stop-minecraft = {
      serviceConfig.Type = "oneshot";
      script = ''
        # Check when service was launched
        servicestartsec=$(
          date -d \
            "$(systemctl show \
                 --property=ActiveEnterTimestamp \
                 minecraft-server.service \
                 | cut -d= -f2)" \
          +%s)

        # Calculate elapsed time
        serviceelapsedsec=$(( $(date +%s) - servicestartsec))

        # Ignore if service just started
        if [ $serviceelapsedsec -lt 180 ]
        then
          echo "Server was just started"
          exit 0
        fi

        PLAYERS=$(
          printf "list\n" \
            | ${pkgs.rcon.out}/bin/rcon -m \
            -H 127.0.0.1 -p ${builtins.toString rconPort} -P ${rconPassword} \
        )

        if echo "$PLAYERS" | grep "are 0 of a"
        then
          echo "Stopping server"
          systemctl stop minecraft-server.service
          systemctl stop hook-minecraft.service
          systemctl stop stop-minecraft.timer
        fi
      '';
    };
  };
}
