{
  userConfig,
  pkgs,
  ...
}: {
  # GTK theme configuration
  # Note: catppuccin.gtk has been deprecated - using manual theme configuration instead
  
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-macchiato-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "macchiato";
      };
    };
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
