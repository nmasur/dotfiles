{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

    home.packages = with pkgs; [
      kubectl # Basic Kubernetes queries
      k9s # Terminal Kubernetes UI
      kubernetes-helm # Helm CLI
      fluxcd # Bootstrap clusters with Flux
      kustomize # Kustomize CLI (for Flux)
    ];

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
