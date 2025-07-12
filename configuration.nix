{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
  materialIconsFont = pkgs.stdenv.mkDerivation {
    name = "material-icons-font";
    src = pkgs.fetchurl {
      url = "https://github.com/google/material-design-icons/raw/master/font/MaterialIcons-Regular.ttf";
      sha256 = "1npdbcbyg6cqwnnm8fb2bfqzpwxhnxv38my8waj0kzyjpl49y57g"; # atualize usando nix-prefetch-url
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/MaterialIcons-Regular.ttf
    '';
  };
  
  dotfiles = ./dotfiles;

  listRecursive = path:
    let
      entries = builtins.readDir path;
    in
      lib.flatten (lib.mapAttrsToList (name: type:
        let
          fullPath = "${path}/${name}";
        in
          if type == "directory"
          then listRecursive fullPath
          else [{
            source = fullPath;
            target = builtins.toString (lib.removePrefix "${toString dotfiles}/" (toString fullPath));
          }]
      ) entries);

  etcFiles = listRecursive dotfiles;

  etcMapped = builtins.listToAttrs (map (entry: {
    name = "xdg/${entry.target}";
    value.source = entry.source;
  }) etcFiles);
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

  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        sansSerif = [ "Roboto" ];
      };
    };

    packages = with pkgs; [
      (nerdfonts.override { fonts=[ "JetBrainsMono" ]; })
      roboto
      materialIconsFont
    ];
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
      sddm.package = pkgs.kdePackages.sddm;
      sddm.wayland.enable = true;
      #autoLogin = {
        #enable = true;
        #user = "sclorentz";
      #};
    };
    libinput.enable = true;
    printing.enable = true;
  };

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.aboutConfig.showWarning" = false;
      "browser.tabs.inTitlebar" = 0;
      "browser.theme.content-theme" = 0;
    };
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
      "composer"
      "docker"
      "emoji"
      "history"
      "rust"
      "1password"
      "sudo"
      "ssh"
      "safe-paste"
      "eza"
      "kitty"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  programs.hyprland.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

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
    process-viewer
    nomacs
    vlc
    prismlauncher
    cmatrix
    # sys
    yad
    brightnessctl
    pavucontrol
    wttrbar
    duf
    eza
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio-fuse
    kdePackages.kio-extras
    neofetch
    hyprland
    hyprpaper
    waybar
    wofi
    brightnessctl
    grim
    slurp
    wl-clipboard
    pamixer
    playerctl
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

  system.stateVersion = "25.05";
}
