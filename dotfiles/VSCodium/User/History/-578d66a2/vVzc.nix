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
          pkgs.gtk4
          pkgs.pkg-config
          pkgs.meson
          pkgs.ninja
          pkgs.bash
          pkgs.webkitgtk_6_0
        ];

        packages = [
          (pkgs.writeShellScriptBin "run" ''
            ninja -C build
            ./build/gtkgreet/gtkgreet -s ./assets/styles.css -b ./assets/wallpaper.jpg -c hyprland
          '')
        ];

        shellHook = ''
        export PKG_CONFIG_PATH="${
            pkgs.webkitgtk_6_0.dev
        }/lib/pkgconfig:${
            pkgs.gtk4.dev
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