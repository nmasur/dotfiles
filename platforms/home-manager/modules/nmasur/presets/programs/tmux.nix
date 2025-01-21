{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.tmux.enable = lib.mkEnableOption "Tmux terminal multiplexer";

  config.home-manager.users.${config.user} = lib.mkIf config.tmux.enable {

    programs.tmux = {
      enable = true;
      baseIndex = 1; # Start windows and panes at 1
      escapeTime = 0; # Wait time after escape is input
      historyLimit = 100000;
      keyMode = "vi";
      newSession = true; # Automatically spawn new session
      plugins = [ ];
      resizeAmount = 10;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "screen-256color";
      extraConfig = ''
        # Horizontal and vertical splits
        bind \\ split-window -h -c '#{pane_current_path}'
        bind - split-window -v -c '#{pane_current_path}'

        # Move between panes with vi keys
        bind h select-pane -L
        bind j select-pane -D
        bind K select-pane -U
        bind l select-pane -R

        # Split out pane
        bind b break-pane

        # Synchronize panes
        bind S set-window-option synchronize-panes

        # Copy mode works as Vim
        bind Escape copy-mode
        bind k copy-mode
        bind C-[ copy-mode

        # Use v to trigger selection
        bind-key -T copy-mode-vi v send-keys -X begin-selection

        # Use y to yank current selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Enable mouse mode
        set -g mouse on

        # Status bar
        set -g status-interval 60                # Seconds between refreshes
        set -g renumber-windows on
        set-option -g status-position bottom

        ## COLORSCHEME: gruvbox dark
        set-option -g status "on"

        # Default statusbar color
        set-option -g status-style bg=colour237,fg=colour223 # bg=bg1, fg=fg1

        # Default window title colors
        set-window-option -g window-status-style bg=colour214,fg=colour237 # bg=yellow, fg=bg1

        # Default window with an activity alert
        set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3

        # Active window title colors
        set-window-option -g window-status-current-style bg=red,fg=colour237 # fg=bg1

        # Pane border
        set-option -g pane-active-border-style fg=colour250 #fg2
        set-option -g pane-border-style fg=colour237 #bg1

        # Message infos
        set-option -g message-style bg=colour239,fg=colour223 # bg=bg2, fg=fg1

        # Writing commands inactive
        set-option -g message-command-style bg=colour239,fg=colour223 # bg=fg3, fg=bg1

        # Pane number display
        set-option -g display-panes-active-colour colour250 #fg2
        set-option -g display-panes-colour colour237 #bg1

        # Clock
        set-window-option -g clock-mode-colour colour109 #blue

        # Bell
        set-window-option -g window-status-bell-style bg=colour167,fg=colour235 # bg=red, fg=bg

        # Theme settings mixed with colors (unfortunately, but there is no cleaner way)
        set-option -g status-justify "left"
        set-option -g status-left-style none
        set-option -g status-left-length "80"
        set-option -g status-right-style none
        set-option -g status-right-length "80"
        set-window-option -g window-status-separator ""

        set-option -g status-left "#[fg=colour248, bg=colour241] #S #[fg=colour241, bg=colour237, nobold, noitalics, nounderscore]"
        set-option -g status-right "#[fg=colour239, bg=colour237, nobold, nounderscore, noitalics]#[fg=colour246,bg=colour239] %Y-%m-%d  %H:%M #[fg=colour248, bg=colour239, nobold, noitalics, nounderscore]"

        set-window-option -g window-status-current-format "#[fg=colour237, bg=colour214, nobold, noitalics, nounderscore]#[fg=colour239, bg=colour214] #I #[fg=colour239, bg=colour214, bold] #W #[fg=colour214, bg=colour237, nobold, noitalics, nounderscore]"
        set-window-option -g window-status-format "#[fg=colour237,bg=colour239,noitalics]#[fg=colour223,bg=colour239] #I #[fg=colour223, bg=colour239] #W #[fg=colour239, bg=colour237, noitalics]"
      '';
    };

    programs.alacritty.settings = {
      # shell.args = [
      #   "--login"
      #   "--init-command"
      #   "tmux attach-session -t noah || tmux new-session -s noah"
      # ];
      key_bindings = [
        {
          key = "H";
          mods = "Super|Shift";
          chars = "\\x02p"; # Previous tmux window
        }
        {
          key = "L";
          mods = "Super|Shift";
          chars = "\\x02n"; # Next tmux window
        }
      ];
    };

    programs.fish.shellAbbrs = {
      ta = "tmux attach-session";
      tan = "tmux attach-session -t noah";
      tnn = "tmux new-session -s noah";
    };
  };
}
