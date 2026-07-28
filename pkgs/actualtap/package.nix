{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}:

buildNpmPackage rec {
  pname = "actualtap";
  version = "1.0.34";

  src = fetchFromGitHub {
    owner = "MattFaz";
    repo = "actualtap";
    rev = "v${version}";
    hash = "sha256-I2yb3WCOXYx/6RXiKjePlpChrr9G1il44OdON/SeVCw=";
  };

  npmDepsHash = "sha256-LlTLwUt0Yja4NSBLbaYPV/keawSJKffno/28rtSj/oQ=";

  dontNpmBuild = true;

  postPatch = ''
    substituteInPlace src/server.js \
      --replace-fail 'port: 3001' 'port: process.env.PORT || 3001'
  '';

  postInstall = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/actualtap
    #!/bin/sh
    exec ${lib.getExe nodejs} $out/lib/node_modules/actualtap/src/server.js "\$@"
    EOF
    chmod +x $out/bin/actualtap
  '';

  meta = with lib; {
    description = "Automatically create transactions in Actual Budget when you use Tap-to-Pay on a mobile device";
    homepage = "https://github.com/MattFaz/actualtap";
    license = licenses.gpl3Only;
    maintainers = [ ];
  };
}
