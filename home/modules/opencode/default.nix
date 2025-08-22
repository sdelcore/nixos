{ inputs, lib, config, pkgs, ... }: 
{
  # Install Node.js to enable npm
  home.packages = with pkgs; [
    nodejs_22
    # Dependencies for hooks
    yq
    ripgrep
  ];

  # Add npm global bin to PATH for user-installed packages
  home.sessionPath = [ 
    "$HOME/.npm-global/bin" 
  ];
  
  # Set npm prefix to user directory
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Create and manage ~/.opencode directory
  home.file.".config/opencode/opencode.jsonc".source = ./opencode.jsonc;
  
  # Copy hook scripts with executable permissions
  #home.file.".claude/hooks/common-helpers.sh" = {
  #  source = ./hooks/common-helpers.sh;
  #  executable = true;
  #};

  # Create necessary directories
  #home.file.".claude/.keep".text = "";
  
  # Install Claude Code on activation
  home.activation.installopencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    PATH="${pkgs.nodejs_22}/bin:$PATH"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    
    if ! command -v opencode >/dev/null 2>&1; then
      echo "Installing opencode..."
      npm i -g opencode-ai@latest 
    else
      echo "opencode is already installed at $(which opencode)"
    fi
  '';

}