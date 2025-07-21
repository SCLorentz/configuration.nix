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
    };
}