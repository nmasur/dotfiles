{ config, pkgs, ... }: {

  home-manager.users.${config.user} = {

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
      '';
    };

    programs.alacritty.settings = {
      shell.args = [
        "--login"
        "--init-command"
        "tmux attach-session -t noah || tmux new-session -s noah"
      ];
      keybindings = [
        {
          key = "H";
          mods = "Super|Shift";
          action = "x02p"; # Previous tmux window
        }
        {
          key = "L";
          mods = "Super|Shift";
          action = "x02n"; # Next tmux window
        }
      ];
    };

  };

}
