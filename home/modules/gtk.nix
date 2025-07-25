{
  userConfig,
  pkgs,
  ...
}: {
  # GTK theme configuration
  catppuccin.gtk = {
    enable = true;
    gnomeShellTheme = true;
  };
  
  gtk = {
    enable = true;
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
    cursorTheme = {
      name = "Yaru";
      package = pkgs.yaru-theme;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
    gtk3 = {
      bookmarks = [
        
      ];
    };
  };
}
