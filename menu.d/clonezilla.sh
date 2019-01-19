#!/bin/bash
#menu: Clonezilla

source functions.sh

cd "$CLONEZILLA_LOCAL_ROOT"
while read folder; do
	IFS='_' read version arch <<< "$folder"

	kernel=$(ls "$folder/live/" | grep -Pom1 '^vmlinuz(\.\w+)?$' || true)
	initrd=$(ls "$folder/live/" | grep -Pom1 '^initrd(\.\w+)?$' || true)
	[[ -z "$kernel" || -z "$initrd" ]] && continue

	relpath=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$folder")
	wwwroot=$(url2grub "$PXE_HTTP_ROOT/$relpath")

	cat <<-EOF
	menuentry 'Clonezilla Live $version ($arch)' {
	  echo 'Loading kernel...'
	  linux $wwwroot/live/$kernel boot=live netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_NFS_ROOT/$relpath/ union=overlay username=user hostname=$version config quiet components noswap edd=on nomodeset noeject ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch="no" vga=788 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1
	  echo 'Loading initial ramdisk...'
	  initrd $wwwroot/live/$initrd
	}
	EOF
done < <(ls | sort -t_ -k1,1r)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
