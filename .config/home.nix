{
  home.stateVersion = "23.11"; # home-manager switch
  home.username = "sclorentz";
  home.homeDirectory = "/home/sclorentz";

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "blur-my-shell@aunetx"
          "logomenu@aryan_k"
          "dash2dock-lite@icedman.github.com"
          "pinned-apps-in-appgrid@brunosilva.io"
          "rounded-window-corners@fxgn"
          "burn-my-windows@schneegans.github.com"
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "just-perfection-desktop@just-perfection"
          "compiz-windows-effect@hermes83.github.com"
          "quick-settings-avatar@d-go"
          "pinned-apps-in-appgrid@brunosilva.io"
          "window-title-is-back@fthx"
          "top-bar-organizer@julian.gse.jsts.xyz"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };

      # Configure individual extensions
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.75;
        noise-amount = 0;
      };
      "org/gnome/shell/extensions/window-title-is-back" = {
        show-title = false;
        fixed-width = false;
      };
      "org/gnome/shell/extensions/quick-settings-avatar" = {
        position = "left";
        remove-button-background = false;
      };
      "org/gnome/shell/extensions/rounded-windows-corners" = {
        corner-radius = 9;
      };
    };
  };
}
