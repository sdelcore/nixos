{ ... }: {
  imports = [
    ../modules/software/localllm
    ../modules/software/android.nix
    ../modules/virtualization/docker.nix
    ../modules/virtualization/libvirt.nix
  ];
}
