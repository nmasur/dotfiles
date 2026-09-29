{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.valheim;

  startScript = pkgs.writeShellScriptBin "valheim-server-start" ''
    set -euo pipefail

    CONFIG_DIR="${cfg.dataDir}/.config/unity3d/IronGate/Valheim"
    mkdir -p "$CONFIG_DIR"

    ${lib.optionalString (cfg.adminList != [ ]) ''
      cat << 'EOF' > "$CONFIG_DIR/adminlist.txt"
      // List of Steam IDs for adminlist ONE per line
      ${lib.concatStringsSep "\n" cfg.adminList}
      EOF
    ''}

    ${lib.optionalString (cfg.permittedList != [ ]) ''
      cat << 'EOF' > "$CONFIG_DIR/permittedlist.txt"
      // List of Steam IDs for permittedlist ONE per line
      ${lib.concatStringsSep "\n" cfg.permittedList}
      EOF
    ''}

    ${lib.optionalString (cfg.bannedList != [ ]) ''
      cat << 'EOF' > "$CONFIG_DIR/bannedlist.txt"
      // List of Steam IDs for bannedlist ONE per line
      ${lib.concatStringsSep "\n" cfg.bannedList}
      EOF
    ''}

    ${
      if cfg.passwordFile != null then
        ''
          if [ ! -f "${cfg.passwordFile}" ]; then
            echo "Valheim password file '${cfg.passwordFile}' not found!" >&2
            exit 1
          fi
          PASS="$(tr -d '\r\n' < '${cfg.passwordFile}')"
        ''
      else
        ''
          PASS="${cfg.password}"
        ''
    }

    if [ ''${#PASS} -lt 5 ]; then
      echo "Valheim server password must be at least 5 characters long!" >&2
      exit 1
    fi

    ARGS=(
      "-name" "${cfg.serverName}"
      "-port" "${toString cfg.port}"
      "-world" "${cfg.worldName}"
      "-password" "$PASS"
      "-public" "${if cfg.public then "1" else "0"}"
    )

    ${lib.optionalString cfg.crossplay ''ARGS+=("-crossplay")''}
    ${lib.optionalString (cfg.saveDir != null) ''ARGS+=("-savedir" "${cfg.saveDir}")''}
    ${lib.concatMapStringsSep "\n" (arg: ''ARGS+=("${arg}")'') cfg.extraArgs}

    exec ${cfg.package}/bin/valheim-server "''${ARGS[@]}"
  '';

in
{

  options.services.valheim = {
    enable = lib.mkEnableOption "Valheim dedicated server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.valheim-server;
      defaultText = lib.literalExpression "pkgs.valheim-server";
      description = "The valheim-server package to use.";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Valheim Server";
      example = "Some cozy server";
      description = "The name listed in the server browser.";
    };

    worldName = lib.mkOption {
      type = lib.types.str;
      default = "Dedicated";
      example = "Midgard";
      description = ''
        The name of the world file to use, without the extension.
        If the world does not exist, the server will generate a world from a random seed.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2456;
      description = ''
        The port on which to listen for incoming connections.
        Ports (port + 1) and (port + 2) are used for Steam queries and routing.
      '';
    };

    crossplay = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable cross-platform play via PlayFab backend.";
    };

    public = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to list the server in the public server browser.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open UDP ports in the firewall.";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The server password in plain text.
        Prefer `passwordFile` to avoid storing passwords in the world-readable Nix store.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
      default = null;
      description = "Path to file containing the server password.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/valheim";
      description = "Directory for valheim server data and state.";
    };

    saveDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Directory where world saves are placed (-savedir). Defaults to Unity config dir in dataDir.";
    };

    adminList = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "72057602627862526" ];
      description = "List of Steam IDs to add to adminlist.txt.";
    };

    permittedList = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "72057602627862526" ];
      description = "List of Steam IDs to add to permittedlist.txt.";
    };

    bannedList = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "72057602627862526" ];
      description = "List of Steam IDs to add to bannedlist.txt.";
    };

    bepinexMods = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "BepInEx mods to install.";
    };

    bepinexConfigs = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Config files for BepInEx mods.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command line arguments to pass to valheim-server.";
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.valheim = {
      isSystemUser = true;
      group = "valheim";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.valheim = { };

    systemd.services.valheim = {
      description = "Valheim dedicated server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ coreutils ];
      serviceConfig = {
        Type = "exec";
        User = "valheim";
        Group = "valheim";
        StateDirectory = "valheim";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = "10s";
        ExecStart = "${startScript}/bin/valheim-server-start";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [
        cfg.port
        (cfg.port + 1)
        (cfg.port + 2)
      ];
    };

    assertions = [
      {
        assertion = cfg.serverName != "";
        message = "services.valheim.serverName must not be empty.";
      }
      {
        assertion = cfg.worldName != "";
        message = "services.valheim.worldName must not be empty.";
      }
      {
        assertion = (cfg.password != null && cfg.password != "") || cfg.passwordFile != null;
        message = "services.valheim requires either services.valheim.password or services.valheim.passwordFile to be set.";
      }
    ];

  };

}
