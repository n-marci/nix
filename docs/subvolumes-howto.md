# Subvolumes: how-to

All commands run on the host. See [subvolumes.md](subvolumes.md) for how it works.

## Add a service

In its module, inside `mkIf cfg.enable`:

```nix
marci.subvolumes.paths."/var/lib/foo".requiredBy = [ "foo.service" ];
```

Deploy. That's it.

## Disable / re-enable

Toggle the service in Nix and deploy. The data is archived on disable and restored on enable.

## Start fresh

```nix
marci.subvolumes.paths."/var/lib/foo".reset = "2026-11-06";  # any new value
```

## Restore an older archive

```sh
systemctl stop foo
ls /var/lib/.subvolumes/archive/var-lib-foo/
new=/var/lib/.subvolumes/archive/var-lib-foo/$(date +%Y%m%dT%H%M%S)
mv --no-copy /var/lib/foo "$new" && btrfs property set -ts "$new" ro true   # keep current data

btrfs subvolume snapshot /var/lib/.subvolumes/archive/var-lib-foo/<old> /var/lib/foo
systemctl start foo
```

## Delete archives

```sh
btrfs subvolume delete /var/lib/.subvolumes/archive/var-lib-foo/<timestamp>
```

## Inspect / troubleshoot

```sh
systemctl list-units 'subvolume*'
journalctl -b -u 'subvolume*' -o cat
cat /var/lib/.subvolumes/managed
```

A failed `subvolume-*` unit keeps its services stopped. Fix the cause and run `systemctl restart subvolume-<path>`.
