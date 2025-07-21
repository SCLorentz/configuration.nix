{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    outputs = { nixpkgs, ... }: {
        devShells.${system}.default = pkgs.mkShell

            buildInputs = with pkgs; [
                bash
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

            packages = [
                (pkgs.writeShellScriptBin "run" ''
                ninja -C build 
                ./build/gtkgreet/gtkgreet
                '')
            ];

            shellHook = ''
            export PKG_CONFIG_PATH="${
                pkgs.gtk3.dev
            }/lib/pkgconfig:${
                pkgs.pango.dev
            }/lib/pkgconfig:${
                pkgs.glib.dev
            }/lib/pkgconfig:${
                pkgs.gdk-pixbuf.dev
            }/lib/pkgconfig:${
                pkgs.cairo.dev
            }/lib/pkgconfig:$PKG_CONFIG_PATH"
            '';
        };
}