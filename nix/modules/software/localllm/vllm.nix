{ inputs, pkgs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
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
