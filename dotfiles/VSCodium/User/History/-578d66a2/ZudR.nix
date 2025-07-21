{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    outputs = { nixpkgs, ... }: {
        devShells.default = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in pkgs.mkShell {
        buildInputs = [
            pkgs.bash
        ];

        packages = [
            (pkgs.writeShellScriptBin "run" ''
            echo "Rodando script.sh..."
            ./script.sh
            '')
        ];

        shellHook = ''
            echo "Digite: run"
        '';
        };
    };

    mkShell {
        buildInputs = [
            gtk3
            pango
            glib
            gdk-pixbuf
            cairo
            meson
            ninja
            pkg-config
            gcc
            json_c
        ];

        shellHook = ''
        export PKG_CONFIG_PATH="${
            gtk3.dev
        }/lib/pkgconfig:${
            pango.dev
        }/lib/pkgconfig:${
            glib.dev
        }/lib/pkgconfig:${
            gdk-pixbuf.dev
        }/lib/pkgconfig:${
            cairo.dev
        }/lib/pkgconfig:$PKG_CONFIG_PATH"
        '';
    }
}