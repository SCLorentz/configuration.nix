{
description = "SCLorentz's system";

inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
        nvf.url = "github:notashelf/nvf";
	hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
};

outputs = { self, nixpkgs, flake-utils, nvf, ... }@inputs: {
        packages."x86_64-linux".default = (nvf.lib.neovimConfiguration {
                pkgs = nixpkgs.legacyPackages."x86_64-linux";
                modules = [ ./modules/nvf-config.nix ];
        }).neovim; 
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
		modules = [
          	        /etc/nixos/configuration.nix
          	        /etc/nixos/hardware-configuration.nix
		        nvf.nixosModules.default
			({ config, lib, ... }: {
     				 _module.args = {
        				inherit inputs;
      				};
    			})
                ];
	};
};
}

