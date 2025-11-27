{ lib, ... }:

{
  # Create symlink for 1Password CLI to communicate with desktop app
  # The desktop app creates its socket at $XDG_RUNTIME_DIR/op-daemon.sock
  # but the CLI expects it at ~/.1password/agent.sock
  home.activation.link1PasswordSocket = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p $HOME/.1password
    if [ -S "$XDG_RUNTIME_DIR/op-daemon.sock" ]; then
      run ln -sf "$XDG_RUNTIME_DIR/op-daemon.sock" "$HOME/.1password/agent.sock"
    fi
  '';
}
