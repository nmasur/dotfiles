{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "slsk-batchdl";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "fiso64";
    repo = "slsk-batchdl";
    rev = "v${version}";
    sha256 = "sha256-P7V7YJUA1bkfp13Glb1Q+NJ7iTya/xgO1TM88z1Nddc=";
  };

  projectFile = "slsk-batchdl/slsk-batchdl.csproj";
  nugetDeps = ./nuget-deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  # Patch the project file to use .NET 8
  postPatch = ''
    substituteInPlace slsk-batchdl/slsk-batchdl.csproj \
      --replace-fail "net6.0" "net8.0"
  '';

  doCheck = false;

  meta = with lib; {
    description = "A batch downloader for Soulseek";
    homepage = "https://github.com/fiso64/slsk-batchdl";
    platforms = platforms.linux;
    mainProgram = "slsk-batchdl";
  };
}
