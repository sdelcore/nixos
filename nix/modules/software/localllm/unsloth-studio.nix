{ pkgs, ... }:

# Unsloth Studio is a beta web UI + training stack from unslothai. Upstream
# ships an installer (curl|sh) that creates a Python venv at ~/.unsloth/,
# npm-builds a Vite frontend, and compiles llama.cpp from source. None of
# that fits nixpkgs cleanly — nixpkgs only has the unsloth *library*, not
# the Studio component.
#
# Workaround: give the installer an FHS env to live in. The `unsloth-studio`
# command drops into a chroot with python/node/cmake/CUDA on a standard FHS
# layout, so upstream's installer + build steps Just Work. Studio state
# persists in ~/.unsloth/ (not pure, but isolated to one tree).
#
# Usage:
#   unsloth-studio install   # one-time: runs upstream installer interactively
#   unsloth-studio           # starts the UI on 0.0.0.0:8888
#   unsloth-studio shell     # interactive bash inside the FHS env
#
# No systemd service: like vllm, Studio holds a model in VRAM, so it is
# launched on demand.

let
  port = 8888;

  entry = pkgs.writeShellScript "unsloth-studio-entry" ''
    set -euo pipefail
    state_dir="$HOME/.unsloth"
    # The installer drops a wrapper somewhere under ~/.unsloth or
    # ~/.local/bin; surface both so `unsloth studio` resolves.
    export PATH="$state_dir/bin:$HOME/.local/bin:$PATH"

    # The installer's nvm step runs `git clone https://github.com/...`.
    # Inside this FHS chroot /home is owned by nobody (bwrap UID-remap
    # quirk), so OpenSSH rejects ~/.ssh/config and any ssh-bound clone
    # fails. The user's ~/.config/git/config has an insteadOf rule that
    # rewrites github HTTPS to SSH, so we hide the global gitconfig from
    # the installer to keep its clones on pure HTTPS.
    run_installer() {
      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT
      curl -fsSL https://unsloth.ai/install.sh -o "$tmp"
      GIT_CONFIG_GLOBAL=/dev/null sh "$tmp"
    }

    cmd="''${1:-up}"
    case "$cmd" in
      install)
        run_installer
        ;;
      shell)
        exec bash
        ;;
      up|"")
        if [ ! -d "$state_dir/studio" ]; then
          echo "unsloth studio not installed yet; running upstream installer."
          run_installer
        fi
        exec unsloth studio -H 0.0.0.0 -p ${toString port}
        ;;
      *)
        exec unsloth "$@"
        ;;
    esac
  '';

  # On-demand lifecycle helper for the local Qwen3.6 MTP model. Studio holds
  # the model in VRAM, so we start/stop it explicitly rather than as a
  # service. `stop` reaps the orphaned llama-server child — killing Studio
  # alone leaves it pinning ~22GB of VRAM.
  #
  #   unsloth-model start    # launch Studio (if down) + load model with MTP
  #   unsloth-model stop     # unload + stop Studio, free VRAM
  #   unsloth-model status   # show Studio + loaded model
  #   unsloth-model restart
  #
  # Reads its API key from the opnix secret (nightman only). See pi's
  # home/modules/pi/local-model.nix for the matching client wiring.
  unslothModel = pkgs.writeShellApplication {
    name = "unsloth-model";
    runtimeInputs = with pkgs; [
      curl
      jq
      iproute2 # ss
      procps # pgrep/pkill
      gnugrep
      coreutils
      util-linux # setsid
      bashInteractive
    ];
    text = ''
      PORT=8888
      BASE="http://localhost:''${PORT}"
      SECRET="/var/lib/opnix/secrets/unslothApiKey"
      MODEL="unsloth/Qwen3.6-35B-A3B-MTP-GGUF"
      VARIANT="UD-Q4_K_XL"
      CTX=32768
      LOG="/tmp/unsloth-studio.log"
      PIDFILE="''${HOME}/.unsloth/studio/studio.pid"
      LLAMA_PAT='\.unsloth/llama.cpp/llama-server'

      key() {
        if [ ! -r "''${SECRET}" ]; then
          echo "error: API key not readable at ''${SECRET}" >&2
          exit 1
        fi
        cat "''${SECRET}"
      }

      studio_up() {
        ss -tlnp 2>/dev/null | grep -q ":''${PORT} "
      }

      start() {
        if ! studio_up; then
          echo "› starting unsloth-studio…"
          setsid bash -c "unsloth-studio up > ''${LOG} 2>&1" </dev/null &
          disown
          for _ in $(seq 1 90); do
            if studio_up; then break; fi
            sleep 1
          done
          if ! studio_up; then
            echo "✗ studio failed to bind :''${PORT} (see ''${LOG})"
            exit 1
          fi
        fi
        echo "› loading ''${MODEL} (''${VARIANT}) with MTP…"
        curl -fsS -X POST "''${BASE}/v1/load" \
          -H "Authorization: Bearer $(key)" \
          -H "Content-Type: application/json" \
          -d "{\"model_path\":\"''${MODEL}\",\"gguf_variant\":\"''${VARIANT}\",\"max_seq_length\":''${CTX},\"speculative_type\":\"draft-mtp\",\"spec_draft_n_max\":4}" \
          | jq -r '"  " + (.status // "?") + " — " + (.display_name // .model // "?")'
        echo "✓ ready at ''${BASE}/v1"
      }

      stop() {
        if studio_up; then
          echo "› unloading model…"
          curl -fsS -X POST "''${BASE}/v1/unload" -H "Authorization: Bearer $(key)" >/dev/null 2>&1 || true
          echo "› stopping studio…"
          if [ -r "''${PIDFILE}" ]; then
            kill "$(cat "''${PIDFILE}")" 2>/dev/null || true
          fi
          pid=$(ss -tlnp 2>/dev/null | grep ":''${PORT} " | grep -oE 'pid=[0-9]+' | head -1 | cut -d= -f2 || true)
          if [ -n "''${pid}" ]; then
            kill "''${pid}" 2>/dev/null || true
          fi
        else
          echo "studio not running."
        fi
        # Studio spawns llama-server as a child; killing Studio orphans it and
        # it keeps the model pinned in VRAM. Sweep any survivor to free VRAM.
        if pgrep -f "''${LLAMA_PAT}" >/dev/null 2>&1; then
          echo "› reaping llama-server…"
          pkill -f "''${LLAMA_PAT}" 2>/dev/null || true
          sleep 2
          pkill -9 -f "''${LLAMA_PAT}" 2>/dev/null || true
        fi
        if studio_up; then
          echo "✗ studio still up on :''${PORT}"
          exit 1
        fi
        echo "✓ stopped (VRAM freed)"
      }

      status() {
        if studio_up; then
          echo "studio: up on :''${PORT}"
          printf 'loaded: '
          curl -fsS -H "Authorization: Bearer $(key)" "''${BASE}/v1/models" \
            | jq -r '(.data | if length>0 then .[].id else "none" end)'
        else
          echo "studio: down"
        fi
      }

      case "''${1:-}" in
        start|load) start ;;
        stop) stop ;;
        status) status ;;
        restart)
          stop || true
          start
          ;;
        *)
          echo "usage: unsloth-model {start|stop|status|restart}"
          exit 1
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [
    unslothModel
    (pkgs.buildFHSEnv {
      name = "unsloth-studio";

      targetPkgs = p: with p; [
        bashInteractive
        coreutils
        curl
        wget
        git
        gnused
        gnugrep
        gawk
        which
        file
        gnumake
        cmake
        ninja
        gcc
        binutils
        pkg-config

        python311
        python311Packages.pip
        python311Packages.virtualenv

        # nodejs_24 (npm 11+); setup.sh requires node >=22.12 AND npm >=11
        # — nodejs_22 ships npm 10.9, which trips the installer into the
        # nvm fallback that doesn't survive this FHS.
        nodejs_24

        openssl
        openssl.dev
        zlib
        zlib.dev
        libffi
        # llama.cpp's cmake build needs libcurl headers; upstream's
        # detector prints the apt name (libcurl4-openssl-dev) and bails.
        curl.dev
        stdenv.cc.cc.lib

        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
        cudaPackages.libcublas
      ];

      profile = ''
        export CUDA_HOME=${pkgs.cudaPackages.cudatoolkit}
        export LD_LIBRARY_PATH=/run/opengl-driver/lib:''${LD_LIBRARY_PATH:-}
        export PATH=/run/opengl-driver/bin:$PATH
      '';

      runScript = entry;
    })
  ];
}
