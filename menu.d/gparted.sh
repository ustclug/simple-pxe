#!/bin/bash
#menu: GParted Live
#root: gparted

source functions.sh
cd "$LOCAL_PATH"

while read folder; do
	IFS='_' read version arch <<< "$folder"

	kernels=( "$folder/live/vmlinuz"* )
	initrds=( "$folder/live/initrd"* )
	[[ -f "${kernels[0]}" && -f "${initrds[0]}" ]] || continue

	grub_linux_entry \
		"Clonezilla Live $version ($arch)" \
		"$GRUB_PATH/${kernels[0]}" \
		"$GRUB_PATH/${initrds[0]}" \
		"boot=live netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_PATH/$folder/ union=overlay username=user config quiet components noswap ip= net.ifnames=0 nosplash"
done < <(ls | sort -t_ -k1,1r)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
