# configuration.nix

thanks https://github.com/JaKooLit

## Todo:

- [ ] migration tool
- [ ] firefox patched
  - Remove Telemetry;
  - Duckduck Go as default engine;
  - Custom appearence;
- [ ] kde dolphin patched
  - Remove services related to KDE;
  - Custom appearence;
- [ ] custom kernel patches
  - linux zen (or similar);
  - patches from WSA kernel;
- [ ] local version control for updates
  - auto updates on reboot;
  - fail handler with nix versions;
- [ ] active '/' with zfs
- [ ] protonDB patched

## Useful commands

```shell
sudo nix-collect-garbage -d
```

```shell
sudo nixos-rebuild switch --flake .#
```

```shell
nixos-generate-config
```
