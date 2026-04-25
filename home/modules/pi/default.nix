{ inputs, lib, config, pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs_22
  ];

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # Load OPENCODE_API_KEY from opnix secret so pi can use OpenCode Zen.
  # Pi has built-in support for the `opencode` provider and reads this env var.
  home.sessionVariablesExtra = ''
    if [ -r /var/lib/opnix/secrets/opencodeApiKey ]; then
      export OPENCODE_API_KEY=$(cat /var/lib/opnix/secrets/opencodeApiKey)
    fi
  '';

  # Install pi coding agent globally under ~/.npm-global so npm doesn't try to
  # write into the nix store. Skips if already installed.
  home.activation.installPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    export npm_config_prefix="$HOME/.npm-global"
    mkdir -p "$HOME/.npm-global"
    if [ ! -x "$HOME/.npm-global/bin/pi" ]; then
      echo "Installing pi coding agent..."
      ${pkgs.nodejs_22}/bin/npm install -g @mariozechner/pi-coding-agent
    else
      echo "pi is already installed at $HOME/.npm-global/bin/pi"
    fi
  '';
}
