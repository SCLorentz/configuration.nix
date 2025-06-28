# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# sudo nixos-rebuild switch

{ config, pkgs, lib, ... }:
let
  nixSoftwareCenterPkg = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Habilita o módulo ZFS no kernel
  boot.supportedFilesystems = [ "zfs" ];
  
  # Carrega o módulo ZFS no initrd (importante para root on ZFS)
  boot.initrd.supportedFilesystems = [ "zfs" ];
  
  # Ativa o serviço ZFS
  services.zfs = {
    enable = true;
    autoScrub.enable = true;  # opcional, faz scrub periódico
    autoSnapshot.enable = true;  # opcional, snapshots automáticos
  };
  
  # Para usar ZFS como raiz (root):
  boot.zfs.devNodes = "/dev/disk/by-uuid"; # ou by-id, dependendo da sua config
  
  # (Opcional) Define o pool de boot, se ZFS for usado como raiz
  boot.zfs.root = "zpool_name/path";
  
  # Outros ajustes úteis (opcional)
  networking.hostId = "deadbeef";
  networking.hostName = "nixos";        # Define your hostname.
  networking.wireless.enable = true;    # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  #services.xserver.enable = true; X11
  programs.sway.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.docker.enable = true;

  boot.plymouth = {
    enable = true;
    #themePackages = [ pkgs.plymouth-matrix-theme ];
    theme = "fade-in";
  };

  #services.docker.enable = true;
  services.flatpak.enable = true;
  programs.chromium.enable = true;
  #programs.firefox.enable = true;

  programs.chromium = {
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

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  #systemd.user.services.dconf.enable = true;
  #systemd.user.services.waylock.enable = true;

  #systemd.user.services.dconf = {
    #description = "Set GNOME lock screen settings";
    #wantedBy = [ "default.target" ];
    #serviceConfig.ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/desktop/screensaver/lock-enabled false";
    #serviceConfig.Type = "oneshot";
    #serviceConfig.RemainAfterExit = true;
  #};

  # Configuração do waylock
  #systemd.user.services.waylock = {
    #description = "Lock screen with Waylock";
    #wantedBy = [ "default.target" ];
    #serviceConfig.ExecStart = "${pkgs.waylock}/bin/waylock";
    #serviceConfig.Type = "oneshot";
    #serviceConfig.RemainAfterExit = true;
  #};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  #console.keyMap = "br-abnt2";

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
      ungoogled-chromium
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # dev
   	vim
    git
    zed-editor
    # bloatware
   	#ungoogled-chromium
    chromium
   	nixSoftwareCenterPkg
   	warp-terminal
    vaapiVdpau
    loupe
    celluloid
    musicpod
    image-roll
    gnome-tweaks
    spot
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
  	gnomeExtensions.compiz-windows-effect
    gnomeExtensions.one-click-bios
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.dash-to-dock
  ];

  xdg.mime.defaultApplications = {
    "text/*" = "zed-editor.desktop";
    "application/x-zerosize" = "zed-editor.desktop";
    "application/xhtml+xml" = "ungoogled-chromium.desktop";
    "application/pdf" = "ungoogled-chromium.desktop";
    "x-scheme-handler/https" = "ungoogled-chromium.desktop";
    "x-scheme-handler/http" = "ungoogled-chromium.desktop";
    "x-scheme-handler/ftp" = "ungoogled-chromium.desktop";
    "x-scheme-handler/chrome" = "ungoogled-chromium.desktop";
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
