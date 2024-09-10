{
  description = "Christian's Nix Infra Configuration";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    
  };

  outputs = { self, darwin, nixpkgs, home-manager, nixos-generators, sops-nix, ... }@inputs:
  let 

    inherit (darwin.lib) darwinSystem;
    inherit (nixpkgs.lib) attrValues makeOverridable optionalAttrs singleton;

    vars = {
    };

    mac_vars = {
      inherit (vars);
    };

    linux_vars = {
      inherit (vars);
      user = "christian";
      home = "/home/christian";
    };

    # Configuration for `nixpkgs`
    nixpkgsConfig = {
      config = { allowUnfree = true; };
      overlays = attrValues self.overlays ++ singleton (
        # Sub in x86 version of packages that don't build on Apple Silicon yet
        final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86)
            idris2
            nix-index
            niv
            purescript;
        })
      );
    }; 
  in
  {
    # My `nix-darwin` configs
      
    darwinConfigurations = (
      import ./darwin {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager darwin nixpkgsConfig mac_vars;
      }
    );

    nixosModules.proxmox = {config, ...}: {
      imports = [
        nixos-generators.nixosModules.all-formats
      ];
      nixpkgs.hostPlatform = "x86_64-linux";
    };

    nixosModules.raspberrypi = {config, ...}: {
      imports = [
        nixos-generators.nixosModules.all-formats
      ];
      nixpkgs.hostPlatform = "aarch64-linux";
    };

    nixosConfigurations.humantorch = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./proxmox
        ./proxmox/humantorch
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        sops-nix.nixosModules.sops
      ];
    };

    nixosConfigurations.wolverine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./bare
        ./bare/wolverine
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        sops-nix.nixosModules.sops
      ];
    };

    nixosConfigurations.nickfury = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        self.nixosModules.raspberrypi
        ./raspberrypi
        ./raspberrypi/nickfury
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
    # Overlays --------------------------------------------------------------- {{{
    overlays = {
      # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          pkgs-x86 = import nixpkgs {
            system = "x86_64-darwin";
            inherit (nixpkgsConfig) config;
          };
        }; 
      };


 };
}
