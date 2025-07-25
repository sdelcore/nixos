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
        sops-nix.url = "github:Mic92/sops-nix";
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
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
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
        sops-nix,
        catppuccin,
        nixvirt,
        spicetify-nix,
        zen-browser
    }:
    let 
        system = "x86_64-linux";

        # Common modules for all systems
        commonModules = [
            nur.modules.nixos.default
            sops-nix.nixosModules.sops
            nixvirt.nixosModules.default
        ];

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
            home-manager.users.sdelcore = import homeFile;
            home-manager.sharedModules = [
                nur.modules.homeManager.default
                catppuccin.homeModules.catppuccin
            ];
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = extraSpecialArgs;
        };

        # System configuration factory
        mkSystem = hostname: { extraModules ? [], homeFile ? null, extraHomeSpecialArgs ? {} }:
            nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs; };
                modules = commonModules ++ [
                    ./nix/${hostname}.configuration.nix
                    unstableOverlay
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerConfig (if homeFile != null then homeFile else ./home/${hostname}.nix) 
                        ({ inherit inputs; } // extraHomeSpecialArgs))
                ] ++ extraModules;
            };
    
    in {
        nixosConfigurations = {
            dayman = mkSystem "dayman" {
                extraModules = [ 
                    disko.nixosModules.disko
                    spicetify-nix.nixosModules.default
                ];
                extraHomeSpecialArgs = { inherit system; };
            };
            
            nightman = mkSystem "nightman" {
                extraModules = [ spicetify-nix.nixosModules.default ];
            };
            
            wise18 = mkSystem "wise18" {
                extraModules = [ disko.nixosModules.disko ];
            };
        };
    };
}