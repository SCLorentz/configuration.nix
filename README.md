# configuration.nix

for some reason this works on my old laptop but not on my vm

```shell
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix --show-trace --upgrade
```

```shell
sudo nix-collect-garbage -d
```
