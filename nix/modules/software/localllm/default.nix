{ ... }: {
  # Local LLM tooling.
  #
  # - ollama: NixOS service module on unstable's ollama-cuda. Replaces
  #   the previous Docker container; same port, same data dir.
  # - vllm: package only, no service. vLLM hard-allocates VRAM on
  #   startup, so we keep it as a CLI and let it be launched on demand
  #   (manually for now, eventually via a control panel like
  #   0xSero/vllm-studio once that stabilizes).
  imports = [
    ./ollama.nix
    ./vllm.nix
  ];
}
