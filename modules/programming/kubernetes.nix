{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [ kubectl k9s ];

    programs.fish.shellAbbrs = {
      k = "kubectl";
      pods = "kubectl get pods -A";
      nodes = "kubectl get nodes";
      deploys = "kubectl get deployments -A";
      dash = "kube-dashboard";
      ks = "k9s";
    };

  };

}
