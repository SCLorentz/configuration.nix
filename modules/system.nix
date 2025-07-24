{ config, pkgs, lib, ... }:
let
  inherit (lib) concatStringsSep mkDefault mkIf mkOption types pipe;

  currentZfs = config.boot.zfs.package;
in
{
  networking = {
    hostId = "deadbeef";
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";
  console.keyMap = "br-abnt2";

  zramSwap.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  hardware.enableAllFirmware = true;
  services.auto-cpufreq.enable = true;

  boot = {
	loader = {
	  systemd-boot.enable = true;
	  systemd-boot.editor = false;
	  systemd-boot.configurationLimit = 5;
	  efi.canTouchEfiVariables = true;
	  timeout = 0;
	};
	zfs = {
	  requestEncryptionCredentials = true;
	  devNodes = "/dev/disk/by-uuid";
	  #extraPools = [ "rpool" ];
	};
	supportedFilesystems = [ "zfs" "ntfs" "exfat" ];
	kernelModules = [
	  "kvm-intel"
	  "zfs"
	  "binder"
	  "binderfs"
	  "ashmem_linux"
	  "vboxdrv"
	];
	initrd.supportedFilesystems = [ "zfs" ];
	initrd.systemd.enable = true;

	plymouth = {
		enable = true;
		theme = "sphere";
		themePackages = with pkgs; [
			(adi1090x-plymouth-themes.override {
				selected_themes = [ "sphere" "unrap" ];
		 	})
		];
	};
	
	consoleLogLevel = 0;
	kernelParams = [
	  "quiet"
	  "udev.log_level=3"
	  "rd.systemd.show_status=false"
	  "rd.udev.log_level=3"
	  "splash"
	  "zswap.enabled=1"
	  "zswap.compressor=lz4"
    	  "zswap.max_pool_percent=20"
    	  "zswap.shrinker_enabled=1"
	  "plymouth.ignore-serial-consoles"
	  "vt.global_cursor_default=0"
	  "vt.default_vt=7"
	  "pcie_aspm=force"
  	  "intel_iommu=on"
  	  "nvme.noacpi=1"
	];
	initrd.verbose = false;

	kernelPackages = pkgs.linuxPackages_zen;

	extraModulePackages = with config.boot.kernelPackages; [
    		v4l2loopback
    		xpadneo
  	];
  };

  services = {
	zfs = {
	  autoScrub.enable = true;
	  autoSnapshot.enable = true;
	};
  };
}
