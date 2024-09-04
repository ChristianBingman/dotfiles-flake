{ lib, inputs, nixpkgs, darwin, home-manager, nixpkgsConfig, mac_vars, ... }:
let
  system = "aarch64-darwin";
in
{
  CBINGMAN-M-0076 = darwin.lib.darwinSystem {
    inherit system;
    specialArgs = { inherit inputs mac_vars; };
    modules = [ 
      ./work-laptop
      ./common.nix
      # `home-manager` module
      home-manager.darwinModules.home-manager
      {
        nixpkgs = nixpkgsConfig;
        # `home-manager` config
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
  deadpool = darwin.lib.darwinSystem {
    inherit system;
    specialArgs = { inherit inputs mac_vars; };
    modules = [ 
      ./personal-laptop
      ./common.nix
      # `home-manager` module
      home-manager.darwinModules.home-manager
      {
        nixpkgs = nixpkgsConfig;
        # `home-manager` config
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
