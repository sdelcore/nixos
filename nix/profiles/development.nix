{ ... }: {
  imports = [
    ../modules/software/ollama.nix
    ../modules/virtualization/docker.nix
    ../modules/virtualization/libvirt.nix
  ];
}
