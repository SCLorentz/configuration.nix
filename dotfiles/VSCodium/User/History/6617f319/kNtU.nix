with import <nixpkgs> {};

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