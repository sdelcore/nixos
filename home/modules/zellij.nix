{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
        theme = "catppuccin-macchiato";
    };
  };

  xdg.configFile = {
    "zellij/config.kdl".text = # kdl
      ''
        show_startup_tips false
        keybinds {
          unbind "Ctrl q"
        }
      '';
  };
}