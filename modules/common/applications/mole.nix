{
  config,
  pkgs,
  lib,
  ...
}:

let

  # Build kdl-py
  kdl-py = pkgs.python311.pkgs.buildPythonPackage rec {
    pname = "kdl-py";
    version = "1.2.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-Y/P0bGJ33trc5E3PyUZyv25r8zMLkBIuATTCKFfimXM=";
    };
    build-system = [ pkgs.python311.pkgs.setuptools ];
    # has no tests
    doCheck = false;
  };

  mole = pkgs.python311.pkgs.buildPythonPackage rec {
    pname = "mole";
    version = "0.7.1";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "eblume";
      repo = pname;
      rev = "30bb052a97050b1fa89c287855d834f7952b195a";
      sha256 = "sha256-DUWsfyICCfFQ2ZQBYSQVoA3eLdKC8djUylKgGdHIyJo=";
    };

    patches = [
      (builtins.toString (
        pkgs.writeText "pyproject.toml.patch" ''
          diff --git a/pyproject.toml b/pyproject.toml
          index 12ce0f5..787e978 100644
          --- a/pyproject.toml
          +++ b/pyproject.toml
          @@ -12,11 +12,11 @@ packages = [
           [tool.poetry.dependencies]
           python = "^3.11"
           # Now back to the regular dependencies
          -typer = {extras = ["all"], version = "^0.9"}
          +typer = {extras = ["all"], version = "^0.12"}
           todoist-api-python = "^2.1.3"
           openai = "^1.2.4"
           rich = "^13.4.2"
          -watchdog = "^3.0.0"
          +watchdog = "^4.0.0"
           pydub = "^0.25.1"
           requests = "^2.31.0"
           pyyaml = "^6.0.1"
        ''
      ))
    ];

    # Used during build time
    nativeBuildInputs = [ pkgs.python311Packages.poetry-core ];

    # Used during run time
    buildInputs = [
      pkgs._1password
      pkgs.nb-cli
    ];

    # Both build and run time
    propagatedBuildInputs = [
      pkgs.python311Packages.typer
      pkgs.python311Packages.todoist-api-python
      pkgs.python311Packages.openai
      pkgs.python311Packages.rich
      pkgs.python311Packages.watchdog
      pkgs.python311Packages.pydub
      pkgs.python311Packages.requests
      pkgs.python311Packages.pyyaml
      pkgs.python311Packages.pydantic
      pkgs.python311Packages.pendulum
      kdl-py
      pkgs.ffmpeg
    ];

    build-system = [ pkgs.python311.pkgs.setuptools ];

    # has no tests
    doCheck = false;

  };

in
{

  options = {
    mole = {
      enable = lib.mkEnableOption {
        description = "Enable Mole.";
        default = false;
      };
    };
  };

  config = lib.mkIf config.mole.enable {
    home-manager.users.${config.user} = {
      home.packages = [ mole ];
    };
  };
}
