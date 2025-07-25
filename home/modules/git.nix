{userConfig, ...}: {
  # Install git via home-manager module
  catppuccin.delta.enable = true;
  
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        keep-plus-minus-markers = true;
        light = false;
        line-numbers = true;
        navigate = true;
        width = 280;
      };
    };
    extraConfig = {
      pull.rebase = "true";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
    includes = [
      {
        condition = "gitdir:~/src/";
        contents = {
          user = {
            name = "sdelcore";
            email = "sdelcore@gmail.com";
          };
        };
      }
      {
        condition = "gitdir:~/wiselab/";
        contents = {
          user = {
            name = "Spencer Delcore";
            email = "sdelcore@uwaterloo.ca";
          };
        };
      }
    ];
  };
}
