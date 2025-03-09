# Gitea Actions is a CI/CD service for the Gitea source code server, meaning it
# allows us to run code operations (such as testing or deploys) when our git
# repositories are updated. Any machine can act as a Gitea Action Runner, so
# the Runners don't necessarily need to be running Gitea. All we need is an API
# key for Gitea to connect to it and register ourselves as a Runner.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.gitea-runner-local;
in

{
  options.nmasur.presets.services.gitea-runner-local.enable =
    lib.mkEnableOption "Gitea Actions runner local to Gitea instance";

  config = lib.mkIf cfg.enable {

    services.gitea-actions-runner.instances.${config.networking.hostName} = {
      enable = true;
      labels = [
        # Provide a Debian base with NodeJS for actions
        # "debian-latest:docker://node:18-bullseye"
        # Fake the Ubuntu name, because Node provides no Ubuntu builds
        # "ubuntu-latest:docker://node:18-bullseye"
        # Provide native execution on the host using below packages
        "native:host"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget
      ];
      name = config.networking.hostName;
      url = "https://${hostnames.git}";
      tokenFile = config.secrets.giteaRunnerToken.dest;
    };

    # Make sure the runner doesn't start until after Gitea
    systemd.services."gitea-runner-${config.networking.hostName}".after = [ "gitea.service" ];

    # API key needed to connect to Gitea
    secrets.giteaRunnerToken = {
      source = ./gitea-runner-token.age; # TOKEN=xyz
      dest = "${config.secretsDirectory}/gitea-runner-token";
    };
    systemd.services.giteaRunnerToken-secret = {
      requiredBy = [
        "gitea-runner-${
          config.services.gitea-actions-runner.instances.${config.networking.hostName}.name
        }.service"
      ];
      before = [
        "gitea-runner-${
          config.services.gitea-actions-runner.instances.${config.networking.hostName}.name
        }.service"
      ];
    };
  };
}
