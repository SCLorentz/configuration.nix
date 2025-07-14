{ config, pkgs, lib, ... }:

{
  programs = {
  	firefox = {
	  enable = true;
	};

	zsh = {
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

	hyprlock.enable = true;
	hyprland.enable = true;

	steam = {
	  enable = true;
	  gamescopeSession.enable = true;
	  remotePlay.openFirewall = true;
	  dedicatedServer.openFirewall = true;
	};
  };
  users.defaultUserShell = pkgs.zsh;

  qt = {
	enable = true;
	platformTheme = "gnome";
	style = "adwaita-dark";
  };

  environment.systemPackages = with pkgs; [
    	# Shell
    	vim
    	git
    	oh-my-zsh
    	kitty
    	nixos-generators
	android-tools
	duf
	eza
    	# bloatware
      	sddm-sugar-dark
      	vscode
    	process-viewer
    	nomacs
    	vlc
	cmatrix
	## Games
    	prismlauncher
    	graalvm-ce
    	# sys
	## Qt
	qt5.qtquickcontrols2
	qt5.qtgraphicaleffects
	qt5.qtquickcontrols
	qt5.qtbase
      	qt5.qtsvg
      	qt5.qtdeclarative
      	qt5.qtgraphicaleffects
      	## KDE
      	kdePackages.dolphin
      	kdePackages.qtsvg
      	kdePackages.kio-fuse
      	kdePackages.kio-extras
      	neofetch
      	## Hyprland
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
        yad
        brightnessctl
        pavucontrol
        wttrbar
    	# libs
    	ffmpeg
    	libva
    	imagemagick
  ];
}

