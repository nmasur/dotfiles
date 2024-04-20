{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.kubernetes.enable = lib.mkEnableOption "Kubernetes tools.";

  config = lib.mkIf config.kubernetes.enable {
    home-manager.users.${config.user} = {

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
        dash = "kube-dashboard";
        ks = "k9s";
      };

      # Terminal Kubernetes UI
      programs.k9s = {
        enable = true;
        settings = {
          k9s = {
            ui = {
              enableMouse = true;
              headless = true;
              logoless = true;
              crumbsless = false;
              skin = "main";
            };
          };
        };
        skins = {
          main = {
            k9s = {
              body = {
                fgColor = config.theme.colors.base06;
                bgColor = "default";
                logoColor = config.theme.colors.base02; # *blue ?
              };
              # Search bar
              prompt = {
                fgColor = config.theme.colors.base06;
                bgColor = "default";
                suggestColor = config.theme.colors.base03;
              };
              # Header left side
              info = {
                fgColor = config.theme.colors.base04;
                sectionColor = config.theme.colors.base05;
              };
              dialog = {
                fgColor = config.theme.colors.base06;
                bgColor = "default";
                buttonFgColor = config.theme.colors.base06;
                buttonBgColor = config.theme.colors.base0E;
                buttonFocusFgColor = config.theme.colors.base07;
                buttonFocusBgColor = config.theme.colors.base02; # *cyan
                labelFgColor = config.theme.colors.base09;
                fieldFgColor = config.theme.colors.base06;
              };
              frame = {
                border = {
                  fgColor = config.theme.colors.base01;
                  focusColor = config.theme.colors.base06;
                };
                menu = {
                  fgColor = config.theme.colors.base06;
                  keyColor = config.theme.colors.base0E; # *magenta
                  numKeyColor = config.theme.colors.base0E; # *magenta
                };
                crumbs = {
                  fgColor = config.theme.colors.base06;
                  bgColor = config.theme.colors.base01;
                  activeColor = config.theme.colors.base03;
                };
                status = {
                  newColor = config.theme.colors.base04; # *cyan
                  modifyColor = config.theme.colors.base0D; # *blue
                  addColor = config.theme.colors.base0B; # *green
                  errorColor = config.theme.colors.base08; # *red
                  highlightColor = config.theme.colors.base09; # *orange
                  killColor = config.theme.colors.base03; # *comment
                  completedColor = config.theme.colors.base03; # *comment
                };
                title = {
                  fgColor = config.theme.colors.base06;
                  bgColor = "default";
                  highlightColor = config.theme.colors.base09; # *orange
                  counterColor = config.theme.colors.base0D; # *blue
                  filterColor = config.theme.colors.base0E; # *magenta
                };
              };
              views = {
                charts = {
                  bgColor = "default";
                  defaultDialColors = [
                    config.theme.colors.base0D
                    config.theme.colors.base08
                  ];
                  # - *blue
                  # - *red
                  defaultChartColors = [
                    config.theme.colors.base0D
                    config.theme.colors.base08
                  ];
                  # - *blue
                  # - *red
                };
                table = {
                  # List of resources
                  fgColor = config.theme.colors.base06;
                  bgColor = "default";

                  # Row selection
                  cursorFgColor = config.theme.colors.base07;
                  cursorBgColor = config.theme.colors.base01;

                  # Header row
                  header = {
                    fgColor = config.theme.colors.base0D;
                    bgColor = "default";
                    sorterColor = config.theme.colors.base0A; # *selection
                  };
                };
                xray = {
                  fgColor = config.theme.colors.base06;
                  bgColor = "default";
                  cursorColor = config.theme.colors.base06;
                  graphicColor = config.theme.colors.base0D;
                  showIcons = false;
                };
                yaml = {
                  keyColor = config.theme.colors.base0D;
                  colonColor = config.theme.colors.base04;
                  fgColor = config.theme.colors.base03;
                };
                logs = {
                  fgColor = config.theme.colors.base06;
                  bgColor = "default";
                  indicator = {
                    fgColor = config.theme.colors.base06;
                    bgColor = "default";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
