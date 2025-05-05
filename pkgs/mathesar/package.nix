{
  runtimeShell,
  python313,
  python313Packages,
  fetchFromGitHub,
  fetchPypi,
  fetchurl,
  gettext,
  unzip,
  ...
}:
let

  django-modern-rpc = python313Packages.buildPythonPackage rec {
    pname = "django_modern_rpc";
    version = "1.1.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-+LBIfkBxe9lvfZIqPI2lFSshTZBL1NpmCWBAgToyJns=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [
      python313Packages.setuptools
      python313Packages.wheel
      python313Packages.poetry-core
    ];
  };
  django-property-filter = python313Packages.buildPythonPackage rec {
    pname = "django_property_filter";
    version = "1.3.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-dpsF4hm0S4lQ6tIRJ0bXgPjWTr1fq1NSCZP0M6L4Efk=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [
      python313Packages.setuptools
      python313Packages.wheel
      python313Packages.django
      python313Packages.django-filter
    ];
  };
  django-fernet-encrypted-fields = python313Packages.buildPythonPackage rec {
    pname = "django-fernet-encrypted-fields";
    version = "0.3.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-OAMb2vFySm6IXuE3zGaivX3DcmxDjhiep+RHmewLqbM=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [
      python313Packages.setuptools
      python313Packages.wheel
    ];
    propagatedBuildInputs = with python313Packages; [
      django
      cryptography
    ];
  };
  drf-access-policy = python313Packages.buildPythonPackage rec {
    pname = "drf-access-policy";
    version = "1.5.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-EsahQYIgjUBUSi/W8GXbc7pvYLPRJ6kpJg6A3RkrjL8=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [
      python313Packages.setuptools
      python313Packages.wheel
    ];
    propagatedBuildInputs = with python313Packages; [
      pyparsing
      djangorestframework
    ];
  };

  pythonPkg = python313.override {
    self = python313;
    packageOverrides = pyfinal: pyprev: {
      inherit
        django-modern-rpc
        django-property-filter
        django-fernet-encrypted-fields
        drf-access-policy
        # psycopg-binary
        ;
    };
  };

  python = pythonPkg.withPackages (
    ps: with ps; [
      gunicorn
      django
      clevercsv
      django
      dj-database-url
      django-filter
      django-modern-rpc
      django-property-filter
      djangorestframework
      django-fernet-encrypted-fields
      drf-access-policy
      frozendict
      gunicorn
      psycopg
      # psycopg-binary
      psycopg2-binary
      requests
      sqlalchemy
      whitenoise
    ]
  );

  staticAssets = fetchurl {
    url = "https://github.com/mathesar-foundation/mathesar/releases/download/0.2.2/static_files.zip";
    sha256 = "sha256-1X2zFpCSwilUxhqHlCw/tg8C5zVcVL6CxDa9yh0ylGA=";
  };

in
python313Packages.buildPythonApplication rec {
  pname = "mathesar";
  version = "0.2.2";
  src = fetchFromGitHub {
    owner = "mathesar-foundation";
    repo = "mathesar";
    rev = version;
    sha256 = "sha256-LHxFJpPV0GJfokSPzfZQO44bBg/+QjXsk04Ry9uhUAs=";
  };
  format = "other";
  nativeBuildInputs = [ unzip ];
  propagatedBuildInputs = [
    python.pkgs.gunicorn
    python.pkgs.django
  ];
  buildInputs = [
    gettext
  ];
  dependencies = [
    pythonPkg.pkgs.clevercsv
    pythonPkg.pkgs.django
    pythonPkg.pkgs.dj-database-url
    pythonPkg.pkgs.django-filter
    pythonPkg.pkgs.django-modern-rpc
    pythonPkg.pkgs.django-property-filter
    pythonPkg.pkgs.djangorestframework
    pythonPkg.pkgs.django-fernet-encrypted-fields
    pythonPkg.pkgs.drf-access-policy
    pythonPkg.pkgs.frozendict
    pythonPkg.pkgs.gunicorn
    pythonPkg.pkgs.psycopg
    pythonPkg.pkgs.psycopg2-binary
    pythonPkg.pkgs.requests
    pythonPkg.pkgs.sqlalchemy
    pythonPkg.pkgs.whitenoise
  ];

  # Manually unzip the extra zip file into a temporary directory
  postUnpack = ''
    mkdir -p $TMPDIR/unzipped
    unzip ${staticAssets} -d $TMPDIR/unzipped
  '';

  # Override the default build phase to prevent it from looking for setup.py
  # Add any non-Python build commands here if needed (e.g., building frontend assets)
  buildPhase = ''
    runHook preBuild

    echo "Skipping standard Python build phase; application files copied in installPhase."
    # If you had frontend assets to build, you'd run the command here, e.g.:
    # npm install
    # npm run build

    runHook postBuild
  '';

  # This copies the application code into the Nix store output
  installPhase = ''
    runHook preInstall

    # Destination: python's site-packages directory within $out
    # This makes 'import mathesar', 'import db', etc. work more easily.
    INSTALL_PATH="$out/lib/${python.libPrefix}/site-packages/${pname}"
    mkdir -p "$INSTALL_PATH"

    echo "Copying application code to $INSTALL_PATH"

    # Copy all essential source directories needed at runtime
    # Adjust this list based on mathesar's actual structure and runtime needs!
    cp -r mathesar "$INSTALL_PATH/"
    cp -r db "$INSTALL_PATH/"
    cp -r config "$INSTALL_PATH/"
    cp -r translations "$INSTALL_PATH/"
    cp -r mathesar_ui "$INSTALL_PATH/" # If needed

    # Copy the management script
    cp manage.py "$INSTALL_PATH/"

    # Copy assets from unzipped directory
    mkdir -p "$INSTALL_PATH/mathesar/static/mathesar"
    cp -r $TMPDIR/unzipped/static_files/* "$INSTALL_PATH/mathesar/static/mathesar"

    # Create wrapper scripts in $out/bin for easy execution

    mkdir -p $out/bin

    # Wrapper for manage.py
    # It ensures the app code is in PYTHONPATH and runs manage.py
    echo "Creating manage.py wrapper..."
    cat <<EOF > $out/bin/mathesar-manage
    #!${python.interpreter}
    import os
    import sys

    # Add the installation path to the Python path
    sys.path.insert(0, "$INSTALL_PATH")

    # Set DJANGO_SETTINGS_MODULE environment variable if required by mathesar
    # You might need to adjust 'config.settings.production' to the actual settings file used
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')

    # Change directory to where manage.py is, if necessary for relative paths
    # os.chdir("$INSTALL_PATH")

    print(f"Running manage.py from: $INSTALL_PATH/manage.py")
    print(f"Python path includes: $INSTALL_PATH")
    print(f"Executing with args: {sys.argv[1:]}")

    # Find manage.py and execute it
    manage_py_path = os.path.join("$INSTALL_PATH", "manage.py")
    if not os.path.exists(manage_py_path):
        print(f"Error: manage.py not found at {manage_py_path}", file=sys.stderr)
        sys.exit(1)

    # Prepare arguments for execute_from_command_line
    # The first argument should be the script name itself
    argv = [manage_py_path] + sys.argv[1:]

    try:
        from django.core.management import execute_from_command_line
        execute_from_command_line(argv)
    except Exception as e:
        print(f"Error executing manage.py: {e}", file=sys.stderr)
        # Optionally re-raise or exit with error
        import traceback
        traceback.print_exc()
        sys.exit(1)

    EOF
    chmod +x $out/bin/mathesar-manage

    # Wrapper for install
    echo "Creating install wrapper..."
    cat <<EOF > $out/bin/mathesar-install
    #!${runtimeShell}
    # Add the app to the Python Path
    export PYTHONPATH="$INSTALL_PATH:\${"PYTHONPATH:-"}"

    # Set Django settings module if needed
    export DJANGO_SETTINGS_MODULE='config.settings.production'

    # Change to the app directory
    cd "$INSTALL_PATH"
    ${python}/bin/python -m mathesar.install
    EOF
    chmod +x $out/bin/mathesar-install

    # Wrapper for gunicorn (example)
    # Assumes mathesar uses a standard wsgi entry point, e.g., config/wsgi.py
    # Adjust 'config.wsgi:application' if necessary
    echo "Creating gunicorn wrapper..."
    cat <<EOF > $out/bin/mathesar-gunicorn
    #!${runtimeShell}
    # Add the app to the Python Path
    export PYTHONPATH="$INSTALL_PATH:\${"PYTHONPATH:-"}"

    # Set Django settings module if needed
    export DJANGO_SETTINGS_MODULE='config.settings.production'

    # Change to the app directory if gunicorn needs it
    # cd "$INSTALL_PATH"

    # Execute gunicorn, passing along any arguments
    # Ensure the gunicorn package is in propagatedBuildInputs
    exec ${python}/bin/gunicorn config.wsgi:application "\$@"
    EOF
    chmod +x $out/bin/mathesar-gunicorn

    runHook postInstall
  '';
}
