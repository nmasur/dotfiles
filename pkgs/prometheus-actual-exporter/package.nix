{
  lib,
  fetchFromGitHub,
  nodejs_20,
  buildNpmPackage,
  nodePackages,
  python3,
  gcc,
  gnumake,
}:
let

in

buildNpmPackage (finalAttrs: rec {
  pname = "prometheus-actual-exporter";

  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "sakowicz";
    repo = "actual-budget-prometheus-exporter";
    tag = version;
    hash = "sha256-DAmWr1HngxAjhOJW9OnMfDqpxBcZT+Tpew/w/YYJIYU=";
  };

  patches = [ ./tsconfig.patch ];

  npmDepsHash = "sha256-N8xqRYFelolNGTEhG22M7KJ7B5U/uW7o+/XfLF8rHMg=";

  nativeBuildInputs = [
    nodejs_20
    nodePackages.typescript
    python3
    nodePackages.node-gyp
    gcc
    gnumake
  ];

  postPatch = ''
    echo "Removing better-sqlite3 install script before npm install"
    sed -i '/"install"/d' node_modules/better-sqlite3/package.json || true
    sed -i '/"install"/d' package.json || true
  '';

  preBuild = ''
    echo "Disabling prebuilt install script from better-sqlite3"
    find node_modules/better-sqlite3 -name package.json -exec sed -i '/"install"/d' {} +
    rm -f node_modules/better-sqlite3/build/Release/better_sqlite3.node || true
  '';

  buildPhase = ''
    # export npm_config_build_from_source=true
    # export npm_config_unsafe_perm=true
    # export BINARY_SITE=none
    # export PATH=${nodePackages.node-gyp}/bin:$PATH
    # export npm_config_node_gyp=${nodePackages.node-gyp}/bin/node-gyp

    # npm rebuild better-sqlite3 --build-from-source --verbose

    npm run build
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -r . $out/lib/prometheus-actual-exporter
    makeWrapper ${lib.getExe nodejs_20} $out/bin/prometheus-actual-exporter \
      --add-flags "$out/lib/prometheus-actual-exporter/dist/app.js"
  '';

  postInstall = ''
    echo "Removing prebuilt .node and rebuilding better-sqlite3"

    export npm_config_build_from_source=true
    export npm_config_unsafe_perm=true
    export BINARY_SITE=none
    export PATH=${nodePackages.node-gyp}/bin:$PATH
    export npm_config_node_gyp=${nodePackages.node-gyp}/bin/node-gyp

    sed -i '/"install"/d' node_modules/better-sqlite3/package.json
    rm -f node_modules/better-sqlite3/build/Release/better_sqlite3.node || true

    npm rebuild better-sqlite3 --build-from-source --verbose
  '';

  meta = {
    description = "Prometheus exporter for Actual Budget";
    homepage = "https://github.com/sakowicz/actual-budget-prometheus-exporter";
    mainProgram = "prometheus-actual-exporter";
  };
})
