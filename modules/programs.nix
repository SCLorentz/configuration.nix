{ config, pkgs, lib, ... }:
{
nix.settings.keep-derivations = false;
nix.settings.keep-outputs = false;
nix.settings.auto-optimise-store = true;

nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};

security.sudo-rs.enable = true;

programs = {
	firefox = {
		enable = true;
		policies = {
			DisableTelemetry = true;
			BlockAboutConfig = true;
			BlockAboutProfiles = true;
			BlockAboutSupport = true;
			DontCheckDefaultBrowser = true;
			DisableFirefoxStudies = true;
			DisableSetDesktopBackground = true;
			DisplayMenuBar = false;
			SkipTermsOfUse = true;
			StartDownloadsInTempDirectory = true;
			OverrideFirstRunPage = "";
    			OverridePostUpdatePage = "";
			SearchBar = "unified";
			FirefoxSuggest = {
				SponsoredSuggestions = false;
    			};
		};
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
			"emoji"
			"history"
			"rust"
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
	gamemode.enable = true;
	gamescope.enable = true;
	neovim.enable = true;
};

environment.variables = {
	QT_STYLE_OVERRIDE = lib.mkForce null;
	QT_QPA_PLATFORMTHEME = "qt6ct";
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
	MOZ_ENABLE_WAYLAND = "1";
	MOZ_USE_XINPUT2 = "1";
	EDITOR = "nvim";
};

users.defaultUserShell = pkgs.zsh;

services.upower.enable = true;
services.blueman.enable = true;

hardware = {
	bluetooth.enable = true;
	graphics.enable = true;
};

nixpkgs.config.qt6 = {
	enable = true;
	platformTheme = "qt6ct";
	style = {
    		package = pkgs.utterly-nord-plasma;
      		name = "Utterly Nord Plasma";
	};
	cursorTheme = "default";
};

## spotify ports
networking.firewall = {
	allowedTCPPorts = [ 57621 ];
	allowedUDPPorts = [ 5353 ];
};

environment.systemPackages = with pkgs; [
	# --- Shell ---
	git		# <<- clone repo
	oh-my-zsh	# <<- zsh plugins
	kitty		# <<- terminal emulator
	nixos-generators# <<- iso generator
	android-tools	# <<- adb, connect phone
	duf		# <<- used space viewer
	eza		# <<- ls replacement
	neofetch	# <<- system info
	# --- bloatware ---
	# -- themes --
	sddm-sugar-dark	# <<- (KDE) DM theme
	# --- defaults ---
	process-viewer
	nomacs 		# <<- image viewer
	vlc		# <<- video player
	qtcreator	# <<- native IDE
	cosmic-edit	# <<- text editor
	cosmic-files	# <<- simple file browser
	libsForQt5.booth# <<- camera app
	# -- social --
	psst		# <<- native spotify client
	# -- langs --
	#graalvm-ce 	# <<- Java Virtual Machine
	rustc		# <<- for compilation purposes
	rustup
	cargo
	gcc		# <<- C/C++ compiler
	# --- sys ---
	# -- Qt --
	qt5.qtquickcontrols2
	qt5.qtgraphicaleffects
	qt5.qtquickcontrols
	qt5.qtbase
	qt5.qtsvg
	qt5.qtdeclarative
	qt5.qtgraphicaleffects
	qt5.qtwayland
	libsForQt5.qtstyleplugin-kvantum
    	libsForQt5.qt5ct
	qt6ct
      	qt6.qtwayland
	# --- WM ---
	## Hyprland
	#hyprlandPlugins.hypr-dynamic-cursors
	#hyprcursor
	hyprpanel	# <<- topbar panel
	hyprland	# <<- window tiling manager (GUI)
	rofi		# <<- app launcher
	brightnessctl
	grim
	pamixer
	playerctl
	xwayland	# <<- compability with Xorg apps
	brightnessctl
	pavucontrol
	wttrbar
	cliphist
	xdg-desktop-portal-hyprland
	# --- libs & dependencies ---
	ffmpeg		# <<- image & video lib
	libva
	imagemagick	# <<- image editor
	wireplumber
	libgtop
	bluez
	networkmanager
	dart-sass
	wl-clipboard
	gvfs
	swww
	gtksourceview3
	# wineWowPackages.waylandFull <<- .exe compat.
];
}

