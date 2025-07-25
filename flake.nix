{
description = "SCLorentz's system";

inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
        nvf.url = "github:notashelf/nvf";
};

outputs = { self, nixpkgs, flake-utils, nvf, ... }: {
        packages."x86_64-linux".default = (nvf.lib.neovimConfiguration {
                pkgs = nixpkgs.legacyPackages."x86_64-linux";
                modules = [ ./modules/nvf-config.nix ];
        }).neovim; 
	nixosConfigurations.nixos=nixpkgs.lib.nixosSystem {
                modules = [
          	        ./configuration.nix
          	        /etc/nixos/hardware-configuration.nix
		        nvf.nixosModules.default
                ];
	};
};
}

