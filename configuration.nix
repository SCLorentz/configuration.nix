# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# sudo nixos-rebuild switch

{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
in
{
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "zfs" ];
    zfs.requestEncryptionCredentials = true;
    kernelModules = [ "kvm-intel" "zfs" ];
    initrd.supportedFilesystems = [ "zfs" ];

    plymouth = {
      enable = true;
      theme = "fade-in";
    };

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "splash"
    ];
    initrd.verbose = false;
  };

  services.zfs = {
    autoScrub.enable = true;  # opcional, faz scrub periódico
    autoSnapshot.enable = true;  # opcional, snapshots automáticos
  };

  boot.zfs.devNodes = "/dev/disk/by-uuid";

  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.theme = "robbyrussell";
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh.plugins = [
      "git"
      "alias-finder"
      "catimg"
      "composer"
      "docker"
      "emoji"
      "history"
      "rust"
      "1password"
      "sudo"
      "ssh"
      "safe-paste"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  #services.xserver.enable = true; Xss11
  programs.sway.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.docker.enable = true;

  #services.docker.enable = true;
  services.flatpak.enable = true;

  programs.chromium = {
    enable = true;
    extensions = [
      "glloabhodjfmeoccmdngmhkpmdlakfbn"    # material you
      "gighmmpiobklfepjocnamgkkbiglidom"    # adBlock
    ];
    initialPrefs = {
      "first_run_tabs" = [
          "https://sclorentz.github.io/"
        ];
    };
  };

  # Outros ajustes úteis (opcional)
  networking = {
    hostId = "deadbeef";
    hostName = "nixos";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Configuração de fontes
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" ];
        sansSerif = [ "Liberation Sans" ];
        monospace = [ "Liberation Mono" ];
      };
      enable = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4 --enable-features=OverlayScrollbar";
    };
  };

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.new_user = {
    isNormalUser = true;
    description = "";
    initialPassword = "123";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
  };

  home-manager.users.new_user = {
    home.stateVersion = "18.09";
    home.username = "new_user";
    home.homeDirectory = "/home/new_user";

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
            "window-title-is-back@fthx"
          ];
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
        "org/gnome/desktop/wm/preferences" = {
          button-layout = ":minimize,maximize,close";  # Define a ordem dos botões
        };
      };
    };
  };

  #gtk.theme.package = "Layan-Dark";

  users.users.sclorentz = {
    isNormalUser = true;
    description = "Felipe Lorentz";
    extraGroups = [ "networkmanager" "wheel" ];

    packages = with pkgs; [
      pkgs.android-tools
    ];
  };

  environment.gnome.excludePackages = with pkgs; [
  	gnome-maps
    gnome-tour
    gnome-user-docs
    gnome-text-editor
    gnome-connections
    gnome-photos
    gnome-software
    gnome-console
    gnome-music
    xterm
    nixos-render-docs
    epiphany
    totem
  ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "sclorentz";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # dev
    vim
    git
    zed-editor
    ghostty
    oh-my-zsh
    #alacritty
    catimg
    # bloatware
    theme-obsidian2
    chromium
    nix-software-center
    vaapiVdpau
    loupe
    celluloid
    musicpod
    image-roll
    gnome-tweaks
    spot
    imagemagick
    # sys
    neofetch
    nautilus-python
    home-manager
    swaylock
    gsettings-desktop-schemas
    # libs
    ffmpeg
    libva
    gnome-shell
    # themes & fonts & cursors
    whitesur-icon-theme
    whitesur-cursors
    layan-gtk-theme
    font-awesome
    # extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.logo-menu
    gnomeExtensions.burn-my-windows
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.keep-pinned-apps-in-appgrid
    gnomeExtensions.window-title-is-back
    # non enabled by default extensions
    gnomeExtensions.user-themes
    gnomeExtensions.just-perfection
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.tweaks-in-system-menu
    #gnomeExtensions.compiz-windows-effect
    gnomeExtensions.one-click-bios
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.dash-to-dock
  ];

  xdg.mime.defaultApplications = {
    "text/*" = "zed-editor.desktop";
    "application/x-zerosize" = "zed-editor.desktop";
    "application/xhtml+xml" = "chromium.desktop";
    "application/pdf" = "chromium.desktop";
    "x-scheme-handler/https" = "chromium.desktop";
    "x-scheme-handler/http" = "chromium.desktop";
    "x-scheme-handler/ftp" = "chromium.desktop";
    "x-scheme-handler/chrome" = "chromium.desktop";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
