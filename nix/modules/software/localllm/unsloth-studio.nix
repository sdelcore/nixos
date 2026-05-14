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

    cmd="''${1:-up}"
    case "$cmd" in
      install)
        tmp=$(mktemp)
        trap 'rm -f "$tmp"' EXIT
        curl -fsSL https://unsloth.ai/install.sh -o "$tmp"
        sh "$tmp"
        ;;
      shell)
        exec bash
        ;;
      up|"")
        if [ ! -d "$state_dir/studio" ]; then
          echo "unsloth studio not installed yet; running upstream installer."
          tmp=$(mktemp)
          trap 'rm -f "$tmp"' EXIT
          curl -fsSL https://unsloth.ai/install.sh -o "$tmp"
          sh "$tmp"
        fi
        exec unsloth studio -H 0.0.0.0 -p ${toString port}
        ;;
      *)
        exec unsloth "$@"
        ;;
    esac
  '';
in
{
  environment.systemPackages = [
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

        nodejs_22

        openssl
        openssl.dev
        zlib
        zlib.dev
        libffi
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
