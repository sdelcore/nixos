{ ... }: {
  # Local LLM tooling.
  #
  # - unsloth-studio: FHS-wrapped upstream installer. Provides the
  #   `unsloth-studio` command (install / up / shell). No service —
  #   launched on demand.
  # - gpu-metrics: nvidia_gpu_exporter, scraped by the homelab Prometheus.
  imports = [
    ./unsloth-studio.nix
    ./llama-swap.nix
    ./gpu-metrics.nix
  ];
}
