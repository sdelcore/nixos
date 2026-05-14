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
