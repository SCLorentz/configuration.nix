{
  description = "gtkgreet flake devShell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gtk3
          pkgs.pkg-config
          pkgs.meson
          pkgs.ninja
          pkgs.bash
        ];

        packages = [
          (pkgs.writeShellScriptBin "run" ''
            echo "Rodando script.sh..."
            ./script.sh
          '')
        ];

        shellHook = ''
          echo "Bem-vindo ao ambiente do gtkgreet!"
          echo "Use o comando: run"
          export PKG_CONFIG_PATH="${pkgs.gtk3.dev}/lib/pkgconfig"
        '';
      };
    };
}