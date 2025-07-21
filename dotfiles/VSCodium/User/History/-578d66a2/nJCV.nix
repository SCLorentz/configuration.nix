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
          gtk4
          pkg-config
          meson
          ninja
          bash
          webkitgtk_6_0
          gdb
          scdoc
          cmake
          gtk-layer-shell
          json_c
        ];

        packages = [
          (pkgs.writeShellScriptBin "run" ''
            ninja -C build
            GTK_LAYER_SHELL_DEBUG=1 G_DEBUG=fatal-criticals ./build/gtkgreet/gtkgreet -s ./assets/styles.css -b ./assets/wallpaper.jpg -c hyprland
          '')
          (pkgs.writeShellScriptBin "debug" ''
            gdb --args ./build/gtkgreet/gtkgreet -s ./assets/styles.css -b ./assets/wallpaper.jpg -c hyprland
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