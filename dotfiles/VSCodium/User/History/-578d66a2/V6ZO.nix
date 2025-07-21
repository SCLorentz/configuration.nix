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
            ninja -C build
            ./build/gtkgreet/gtkgreet
          '')
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
      };
    };
}