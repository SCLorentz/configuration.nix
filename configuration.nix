{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
in
{
  imports = [
    ./hardware-configuration.nix
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

  nixpkgs.config.allowUnfree = true;

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
      sddm.package = pkgs.kdePackages.sddm;
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

  programs.hyprland.enable = true;

  networking = {
    hostId = "deadbeef";
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  console.keyMap = "br-abnt2";

  security.rtkit.enable = true;

  users.users.new_user = {
    isNormalUser = true;
    description = "";
  };

  users.users.sclorentz = {
    isNormalUser = true;
    description = "Felipe Lorentz";
    extraGroups = [ "networkmanager" "wheel" ];

    packages = with pkgs; [
      pkgs.android-tools
    ];
  };

  environment.systemPackages = with pkgs; [
    # dev
    vim
    git
    oh-my-zsh
    kitty
    vscode
    catimg
    # bloatware
    firefox
    # sys
    eza
    kdePackages.dolphin
    neofetch
    home-manager
    hyprland
    waybar
    wofi
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

  disabledModules = [ "services/mako.nix" ];

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
# Edit this configuration file to define what should be installed on   
