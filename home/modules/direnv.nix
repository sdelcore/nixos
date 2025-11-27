{pkgs, ...}: {

    programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
            stdlib = ''
              use_op() {
                if ! command -v op &> /dev/null; then
                  log_error "op CLI not found"
                  return 1
                fi

                # Ensure socket symlink exists for desktop app integration
                if [ -S "$XDG_RUNTIME_DIR/op-daemon.sock" ] && [ ! -S "$HOME/.1password/agent.sock" ]; then
                  mkdir -p "$HOME/.1password"
                  ln -sf "$XDG_RUNTIME_DIR/op-daemon.sock" "$HOME/.1password/agent.sock"
                fi

                if printenv | grep -q "op://"; then
                  local failed=0
                  eval "$(printenv | grep "op://" | while IFS='=' read -r key value; do
                    if secret=$(op read "$value" 2>&1); then
                      echo "export $key=\"$secret\""
                    else
                      echo "log_error \"Failed to read $key: $secret\"" >&2
                      echo "failed=1"
                    fi
                  done)"

                  if [ "$failed" = "1" ]; then
                    log_status "Some secrets failed to load. Is 1Password unlocked?"
                    return 1
                  fi
                fi
              }
            '';
        };

}