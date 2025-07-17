# configuration.nix

thanks https://github.com/JaKooLit

## Todo:

- [ ] firefox patched
- [ ] kde dolphin patched
- [ ] custom kernel with WSA patches
- [ ] local version control for updates
- [ ] active '/' with zfs
- [ ] protonDB patched

## Useful commands

```shell
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix --show-trace --upgrade
```

```shell
sudo nix-collect-garbage -d
```

```shell
killall waybar && waybar & disown
```

```shell
sudo nixos-rebuild switch --flake .#
```
