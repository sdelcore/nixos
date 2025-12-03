{...}: {
  # Install alacritty via home-manager module
  catppuccin.alacritty.enable = true;
  
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell.program = "zsh";
      terminal.shell.args = [
        "-l"
        "-c"
        "zellij attach --create workspace"
      ];

      env = {
        TERM = "xterm-256color";
      };

      window = {
        decorations = "none";
        dynamic_title = false;
        dynamic_padding = true;
        dimensions = {
          columns = 170;
          lines = 45;
        };
        padding = {
          x = 5;
          y = 1;
        };
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        size = 8.0;
        normal = {
          family = "MesloLGS Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "MesloLGS Nerd Font";
          style = "Italic";
        };
      };

      selection = {
        semantic_escape_chars = '',│`|:"' ()[]{}<>'';
        save_to_clipboard = true;
      };

      general.live_config_reload = true;
    };
  };
}
