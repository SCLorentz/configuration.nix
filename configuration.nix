{ config, pkgs, ... }:

{
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
  networking.hostId = "deadbeef"; # deve ser estático para ZFS
}
