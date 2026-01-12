{
    description = "A simple NixOS flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        # Home-Manager
        home-manager = {
            url = "github:nix-community/home-manager/release-25.05"; # Stable
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
        catppuccin.url = "github:catppuccin/nix/3ba714046ee32373e88166e6e9474d6ae6a5b734";
        # applications
        nur.url = "github:nix-community/NUR";
        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        voiced = {
            url = "github:sdelcore/voiced";
            inputs.nixpkgs.follows = "nixpkgs";
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
        voiced
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
            home-manager.extraSpecialArgs = { inherit primaryUser; } // extraSpecialArgs;
        };

        # System configuration factory
        mkSystem = hostname: { extraModules ? [], homeFile ? null, extraHomeSpecialArgs ? {} }:
            nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs primaryUser; };
                modules = commonModules ++ [
                    ./nix/${hostname}.configuration.nix
                    unstableOverlay
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerConfig (if homeFile != null then homeFile else ./home/${hostname}.nix) 
                        ({ inherit inputs; } // extraHomeSpecialArgs))
                ] ++ extraModules;
            };
    
        # Standalone home-manager config factory (for non-NixOS systems)
        mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            };
            extraSpecialArgs = { inherit username; };
            modules = [
                catppuccin.homeModules.catppuccin
                ./home/headless.nix
            ];
        };

    in {
        # Standalone home-manager configurations for non-NixOS VMs
        # Usage: nix run home-manager/release-25.05 -- switch --flake .#headless
        homeConfigurations = {
            # Default config using "sdelcore" username
            "sdelcore" = mkHomeConfig "sdelcore";
            # Generic headless config
            "headless" = mkHomeConfig "sdelcore";
        };

        nixosConfigurations = {
            dayman = mkSystem "dayman" {
                extraModules = [ disko.nixosModules.disko ];
                extraHomeSpecialArgs = { inherit system; };
            };

            nightman = mkSystem "nightman" {};

            testvm = mkSystem "testvm" {};
        };
    };
}