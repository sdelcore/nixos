# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Common

default:
    @just --list

update:
    nix flake update

repl:
    nix repl -f flake:nixpkgs

fmt:
    nix fmt

switch name="":
    sudo nixos-rebuild switch --flake .#{{name}}

build name="":
    sudo nixos-rebuild build --flake .#{{name}}

boot name="":
    sudo nixos-rebuild boot --flake .#{{name}}

buildvm name="":
    nixos-rebuild build-vm --flake .#{{name}} --impure
    ./result/bin/run-{{name}}-vm

# Test a host configuration as a VM
testvm name="" *args="":
    ./scripts/test-vm.sh {{args}} {{name}}

# Build VM only (no run)
testvm-build name="":
    ./scripts/test-vm.sh --build-only {{name}}

# Run VM headless with SSH access
testvm-headless name="" port="2222":
    ./scripts/test-vm.sh --headless --ssh-port {{port}} {{name}}

deploy name="" ip="":
    nixos-rebuild boot --flake .#{{name}} --use-remote-sudo --target-host {{ip}}
    ssh {{ip}} sudo reboot now

# Provision with opnix token (1Password service account) to a new machine
provision name="" ip="":
    @mkdir -p /tmp/opnix-provision/etc
    @cp ~/.config/op/service-account-token /tmp/opnix-provision/etc/opnix-token
    @chmod 600 /tmp/opnix-provision/etc/opnix-token
    nix run github:nix-community/nixos-anywhere -- --extra-files /tmp/opnix-provision --flake .#{{name}} root@{{ip}}
    @rm -rf /tmp/opnix-provision
