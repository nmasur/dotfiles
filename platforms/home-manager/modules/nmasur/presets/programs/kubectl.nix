{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.kubectl;
in

{

  options.nmasur.presets.programs.kubectl.enable = lib.mkEnableOption "Kubernetes CLI tools";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      kubectl # Basic Kubernetes queries
      kubernetes-helm # Helm CLI
      fluxcd # Bootstrap clusters with Flux
      kustomize # Kustomize CLI (for Flux)
    ];

    programs.fish.shellAbbrs = {
      k = "kubectl";
      pods = "kubectl get pods -A";
      nodes = "kubectl get nodes";
      deploys = "kubectl get deployments -A";
    };

  };
}
