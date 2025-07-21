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
        buildInputs = with pkgs; [
          gtk3
          pkg-config
          meson
          ninja
          bash
          gtk-layer-shell
        ];

        packages = [
          (pkgs.writeShellScriptBin "run" ''
            ninja -C build
            GTK_LAYER_SHELL_DEBUG=1 ./build/gtkgreet/gtkgreet -s ./assets/styles.css -b ./assets/wallpaper.jpg -c hyprland
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