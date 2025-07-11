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
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    zfs = {
      requestEncryptionCredentials = true;
      devNodes = "/dev/disk/by-uuid";
    };
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "kvm-intel" "zfs" ];
    initrd.supportedFilesystems = [ "zfs" ];

    plymouth = {
      enable = false;
      theme = "fade-in";
    };

    #consoleLogLevel = 0;
    #kernelParams = [
      #"quiet"
      #"udev.log_level=3"
      #"rd.systemd.show_status=false"
      #"rd.udev.log_level=3"
      #"splash"
    #];
    #initrd.verbose = false;
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    displayManager = {
      defaultSession = "hyprland";
      sddm.enable = true;
      sddm.wayland.enable = true;
      #autoLogin = {
        #enable = true;
        #user = "sclorentz";
      #};
    };
    libinput.enable = true;
    printing.enable = true;
    flatpak.enable = true;
  };

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

  # programs.sway.enable = true;
  # virtualisation.waydroid.enable = true;

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

  # Habilita Hyprland
  programs.hyprland.enable = true;

  # Outros ajustes úteis (opcional)
  networking = {
    hostId = "deadbeef";
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

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
      commandLineArgs = "--use-system-title-bar --enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4 --enable-features=OverlayScrollbar";
    };
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

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

    dconf = { };
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # dev
    vim
    git
    ghostty
    oh-my-zsh
    kitty
    vscode
    catimg
    # bloatware
    #chromium
    firefox
    nix-software-center
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
    gsettings-desktop-schemas
    hyprland
    waybar
    wofi
    sddm
    brightnessctl
    grim
    slurp
    wl-clipboard
    pamixer
    playerctl
    xdg-utils
    xwayland
    # libs
    ffmpeg
    libva
    imagemagick
  ];

  xdg.mime.defaultApplications = {
    "text/*" = "code.desktop";
    "application/x-zerosize" = "code.desktop";
    "application/xhtml+xml" = "chromium.desktop";
    "application/pdf" = "chromium.desktop";
    "x-scheme-handler/https" = "chromium.desktop";
    "x-scheme-handler/http" = "chromium.desktop";
    "x-scheme-handler/ftp" = "chromium.desktop";
    "x-scheme-handler/chrome" = "chromium.desktop";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
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
