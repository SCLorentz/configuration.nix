{ config, pkgs, lib, ... }:

{
  networking = {
    hostId = "deadbeef";
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";
  console.keyMap = "br-abnt2";

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
	
	plymouth = { enable = true; theme = "fade-in"; };
	
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

  services = {
	zfs = {
	  autoScrub.enable = true;
	  autoSnapshot.enable = true;
	};
  };
}
