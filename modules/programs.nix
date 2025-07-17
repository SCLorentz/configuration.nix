{ config, pkgs, lib, ... }:
#let
#firefoxBase = pkgs.firefox-unwrapped.overrideAttrs (old: {
#    	postFixup = ''
# 	     	wrapProgram $out/bin/firefox \
#        	--set MOZ_ENABLE_WAYLAND 1 \
#		--set MOZ_USE_XINPUT2 1
#	'';
#});
#in {
{
environment.sessionVariables.NIXOS_OZONE_WL = "1";

security.sudo-rs.enable = true;

programs = {
	firefox = {
		enable = true;
		#package = pkgs.wrapFirefox firefoxBase {};
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
	# Shell
	git
	oh-my-zsh
	kitty
	nixos-generators
	android-tools
	duf
	eza
	tmux
	# bloatware
	## themes
	sddm-sugar-dark
	gruvbox-plus-icons
	## viewer
	vscode
	process-viewer
	nomacs
	vlc
	## social
	spotify
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
	qt5.qtwayland
	libsForQt5.qtstyleplugin-kvantum
    	libsForQt5.qt5ct
	qt6ct
      	qt6.qtwayland
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
	cliphist
	# libs
	ffmpeg
	libva
	imagemagick
];
}

