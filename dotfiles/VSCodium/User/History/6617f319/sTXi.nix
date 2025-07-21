with import <nixpkgs> {};

nixpkgs.overlays = [
    (final: prev: {
      clangWithLibcxx = prev.clang.override {
        enableLibcxx = true;
      };
    })
];

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
        #gcc
        json_c
        pkgs.clangWithLibcxx
        pkgs.lld 
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
    export CXX=clang++
    export CC=clang
    '';
}