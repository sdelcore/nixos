{ inputs, pkgs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = {
      allowUnfree = true;
      # vllm 0.16.0 is marked insecure for CVE-2026-27893 (RCE via
      # trust_remote_code bypass when loading untrusted models) and two DoS
      # issues (CVE-2026-44222/44223) that require an exposed API server. We
      # run vllm as a local on-demand CLI, never as an unattended service, so
      # the practical risk is low. nixpkgs has not yet packaged the patched
      # 0.20.0. Drop this allow once unstable ships vllm >= 0.20.0.
      permittedInsecurePackages = [ "python3.13-vllm-0.16.0" ];
    };
    overlays = [
      (final: prev: {
        python3Packages = prev.python3Packages.overrideScope (pythonFinal: pythonPrev: {
          prometheus-fastapi-instrumentator = pythonPrev.prometheus-fastapi-instrumentator.overridePythonAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace pyproject.toml \
                --replace-fail 'starlette (>=0.30.0,<1.0.0)' 'starlette (>=0.30.0)'
            '';
          });
        });
      })
    ];
  };

  # Unstable vllm 0.16.0's csrc/cpu/utils.hpp calls `at::cpu::L2_cache_size()`,
  # which was removed from the libtorch version unstable currently ships.
  # The function it lives in is only used by CPU inference kernels (we run on
  # CUDA), so replace the call with a 256 KiB constant to unblock the build.
  # Drop this override once nixpkgs unstable updates libtorch or vllm.
  vllm = unstable.vllm.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace csrc/cpu/utils.hpp \
        --replace-fail \
          "const uint32_t l2_cache_size = at::cpu::L2_cache_size();" \
          "const uint32_t l2_cache_size = 256 * 1024;"
    '';
  });
in
{
  # vLLM as a CLI only — no systemd service. vLLM pre-allocates ~90% of
  # VRAM on startup for its KV cache, so it should not run unattended.
  # Launch manually with `vllm serve <model>`.
  environment.systemPackages = [ vllm ];
}
