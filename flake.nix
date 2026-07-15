{
    description = "NixOS + Home Manager configs for dayman (laptop), nightman (desktop), and lab";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        # Home-Manager
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11"; # Stable
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # platform
        opnix = {
            url = "github:brizzbuzz/opnix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvirt = {
            url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # hardware
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # ricing
        catppuccin = {
            url = "github:catppuccin/nix/3ba714046ee32373e88166e6e9474d6ae6a5b734";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # applications
        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        voiced = {
            url = "github:sdelcore/voiced";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sagent = {
            url = "github:sdelcore/sagent";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        wagent = {
            url = "github:sdelcore/wagent";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        droidcode = {
            url = "github:sdelcore/droidcode";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # shared — self-hosted static-site platform; we use its `shared` deploy CLI.
        shared = {
            url = "github:sdelcore/shared";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zjstatus = {
            url = "github:dj95/zjstatus";
        };
    };

    outputs = inputs@{
        self,
        nixpkgs,
        nixpkgs-unstable,
        home-manager,
        nur,
        disko,
        opnix,
        catppuccin,
        nixvirt,
        zen-browser,
        voiced,
        sagent,
        wagent,
        droidcode,
        shared,
        zjstatus
    }:
    let 
        system = "x86_64-linux";

        # Common modules for all systems
        commonModules = [
            nur.modules.nixos.default
            opnix.nixosModules.default
            nixvirt.nixosModules.default
        ];

        # Primary user for all systems
        primaryUser = "sdelcore";

        # Unstable overlay configuration
        unstableOverlay = {
            nixpkgs.overlays = [
                (final: prev: {
                    unstable = import nixpkgs-unstable {
                        inherit system;
                        config.allowUnfree = true;
                    };
                })
            ];
        };

        # Home manager configuration factory
        mkHomeManagerConfig = homeFile: extraSpecialArgs: {
            home-manager.users.${primaryUser} = import homeFile;
            home-manager.sharedModules = [
                nur.modules.homeManager.default
                catppuccin.homeModules.catppuccin
            ];
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
                inherit primaryUser;
                zjstatus = zjstatus.packages.${system}.default;
            } // extraSpecialArgs;
        };

        # System configuration factory
        mkSystem = hostname: { extraModules ? [], extraHomeSpecialArgs ? {} }:
            nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs primaryUser; };
                modules = commonModules ++ [
                    ./nix/${hostname}.configuration.nix
                    unstableOverlay
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerConfig ./home/${hostname}.nix
                        ({ inherit inputs; } // extraHomeSpecialArgs))
                ] ++ extraModules;
            };
    
        # Standalone home-manager config factory (for non-NixOS systems)
        mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            };
            extraSpecialArgs = {
                inherit username;
                zjstatus = zjstatus.packages.${system}.default;
            };
            modules = [
                catppuccin.homeModules.catppuccin
                ./home/headless.nix
            ];
        };

    in {
        # Standalone home-manager configurations for non-NixOS VMs
        # Usage: nix run home-manager/release-25.11 -- switch --flake .#headless
        # Two names for the same standalone config (both build home/headless.nix
        # for user "sdelcore"): "headless" is the descriptive alias, "sdelcore"
        # the convenience default.
        homeConfigurations = {
            "sdelcore" = mkHomeConfig "sdelcore";
            "headless" = mkHomeConfig "sdelcore";
        };

        nixosConfigurations = {
            dayman = mkSystem "dayman" {
                extraModules = [ disko.nixosModules.disko ];
                extraHomeSpecialArgs = { inherit system; };
            };

            nightman = mkSystem "nightman" {};

            testvm = mkSystem "testvm" {};

            lab = mkSystem "lab" {
                extraModules = [ disko.nixosModules.disko ];
                # home/headless.nix's `username ? "sdelcore"` default is not
                # honored when imported as a HM module — pass it explicitly.
                extraHomeSpecialArgs = { username = primaryUser; };
            };
        };
    };
}