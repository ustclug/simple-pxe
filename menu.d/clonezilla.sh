#!/bin/bash
#menu: Clonezilla
#root: clonezilla

source functions.sh
cd "${LOCAL_PATH}" || exit 1

while read -r folder; do
	IFS='_' read -r version arch <<< "${folder}"

	kernels=("${folder}/live/vmlinuz"*)
	initrds=("${folder}/live/initrd"*)
	[[ -f "${kernels[0]}" && -f "${initrds[0]}" ]] || continue

	grub_linux_entry \
		"Clonezilla Live ${version} (${arch})" \
		"${GRUB_PATH}/${kernels[0]}" \
		"${GRUB_PATH}/${initrds[0]}" \
		"boot=live netboot=nfs nfsroot=${PXE_NFS_HOST}:${NFS_PATH}/${folder} union=overlay username=user hostname=clonezilla config quiet components noswap edd=on nomodeset noeject ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no vga=788 ip= net.ifnames=0 splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1"
done < <(ls | sort -t_ -k1,1r)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
