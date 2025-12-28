{ ... }: {
  imports = [
    ../modules/software/ollama.nix
    ../modules/software/android.nix
    ../modules/virtualization/docker.nix
    ../modules/virtualization/libvirt.nix
  ];
}
