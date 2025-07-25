{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = [
      pkgs.vimPlugins.LazyVim
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };
}
