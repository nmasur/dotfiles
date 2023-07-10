{ config, pkgs, lib, ... }:

{
  options.giteaRunner.enable =
    lib.mkEnableOption "Enable Gitea Actions runner.";

  config = lib.mkIf config.giteaRunner.enable {

    services.gitea-actions-runner.instances.${config.networking.hostName} = {
      enable = true;
      labels = [
        # Provide a Debian base with NodeJS for actions
        "debian-latest:docker://node:18-bullseye"
        # Fake the Ubuntu name, because Node provides no Ubuntu builds
        "ubuntu-latest:docker://node:18-bullseye"
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
      url = "https://${config.hostnames.git}";
      tokenFile = config.secrets.giteaRunnerToken.dest;
    };

  };

}
