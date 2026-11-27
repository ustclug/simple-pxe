# simple-pxe: A simple GRUB netboot menu generator

Copy `config.local.example` to `config.local`. Serve `PXE_LOCAL_ROOT` at
`PXE_HTTP_ROOT` and use an address reachable from the boot clients. The live
systems download their compressed root filesystem or ISO into client RAM.
For GParted and Clonezilla, use an IPv4 address in the URL for compatibility
with early boot environments that lack DNS.

Prepare files (network needed):
```
./simple-pxe prepare
```

Ubuntu Live (20.04 and later) needs `jq` during preparation. For each
release and variant, `prepare` downloads the latest ISO in the mirror's
catalog and stores it with its matching kernel and initrd under `http/`.
Run `prepare` before regenerating an existing menu. Older extracted Ubuntu
trees need a matching ISO to boot over HTTP. Existing Arch Linux, GParted
and Clonezilla trees can be reused.

Update menu (no network needed):
```
./simple-pxe menu
```
