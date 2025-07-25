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
    nixos-rebuild build-vm --flake .#{{name}}
    ./result/bin/run-{{name}}-vm

deploy name="" ip="":
    nixos-rebuild boot --flake .#{{name}} --use-remote-sudo --target-host {{ip}}
    ssh {{ip}} sudo reboot now

provision name="" ip="":
    nix run github:nix-community/nixos-anywhere -- --extra-files "/var/lib/sops/age/" --flake .#{{name}} root@{{ip}}
    