{
  lib,
  stdenv,
  fetchSteam,
  buildFHSEnv,
  writeScript,
  steamworks-sdk-redist,
  zlib,
  pulseaudio,
}:

if !stdenv.hostPlatform.isLinux || !stdenv.hostPlatform.isx86_64 then
  null
else
  let
    valheim-server-unwrapped = stdenv.mkDerivation (finalAttrs: {
      pname = "valheim-server-unwrapped";
      version = "1.0.16";

      src = fetchSteam {
        name = "valheim-server";
        appId = "896660";
        depotId = "896661";
        manifestId = "1285123405092214913";
        hash = "sha256-AH9yU0YW0RpgkD9VSGFLj+qIXk3UlvrAgIu9fy/D+N8=";
      };

      dontBuild = true;
      dontConfigure = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        shopt -s nullglob
        cp -r *.so *.debug valheim_server.x86_64 valheim_server_Data $out
        chmod +x $out/valheim_server.x86_64

        runHook postInstall
      '';

      meta = with lib; {
        description = "Valheim dedicated server (unwrapped)";
        homepage = "https://steamdb.info/app/896660/";
        changelog = "https://store.steampowered.com/news/app/892970?updates=true";
        sourceProvenance = with sourceTypes; [
          binaryBytecode
          binaryNativeCode
        ];
        license = licenses.unfree;
        platforms = [ "x86_64-linux" ];
      };
    });
  in
  buildFHSEnv {
    name = "valheim-server";
    pname = "valheim-server";
    version = valheim-server-unwrapped.version;

    runScript = writeScript "valheim-server-wrapper" ''
      export LD_LIBRARY_PATH=${steamworks-sdk-redist}/lib:$LD_LIBRARY_PATH
      export SteamAppId=892970
      exec ${valheim-server-unwrapped}/valheim_server.x86_64 "$@"
    '';

    targetPkgs = pkgs: [
      valheim-server-unwrapped
      steamworks-sdk-redist
      zlib
      pulseaudio
    ];

    passthru = {
      unwrapped = valheim-server-unwrapped;
    };

    meta = valheim-server-unwrapped.meta // {
      description = "Valheim dedicated server";
      mainProgram = "valheim-server";
    };
  }
