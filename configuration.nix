{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
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
	<home-manager/nixos>
	./hardware-configuration.nix
	./modules/system.nix
	#./modules/users.nix
	#./modules/desktop.nix
	./modules/programs.nix
	#./modules/android.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
      	pkgs.nerd-fonts.jetbrains-mono
	roboto
    ];
  };

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    displayManager = {
      	defaultSession = "hyprland";
	sddm = {
      	  enable = true;
      	  theme = "sugar-dark";
      	  package = pkgs.libsForQt5.sddm;
	  wayland.enable = true;
    	};
    };
    libinput.enable = true;
    printing.enable = true;
  };

  security.rtkit.enable = true;

  users.users.new_user = {
    	isNormalUser = true;
    	description  = "";
  };

  users.users.sclorentz = {
    	isNormalUser = true;
    	description  = "Felipe Lorentz";
    	extraGroups  = [ "networkmanager" "wheel" ];
  };

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
      #pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.hyprland.preferred = [ "hyprland" "gtk" ];
    config.common.default = "*";
  };

  disabledModules = [ "services/mako.nix" ];

  system.stateVersion = "25.05";
}
