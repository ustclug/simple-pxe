#!/bin/bash
#menu: Arch Linux
#root: archlinux

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_ARCH_COPYTORAM "Copy RootFS to RAM" \
	y yes "Copy RootFS to RAM" \
	n no  "Mount RootFS via NFS"

IFS=' ' read -r -a mirrors <<< "${ARCHLINUX_MIRROR_BACKUP}"
grub_mirror_selector SP_ARCH_MIRROR "${ARCHLINUX_MIRROR}" "${mirrors[@]}"

while read -r version; do
	bootdir="${GRUB_PATH}/${version}/arch/boot"
	grub_linux_entry \
		"Arch Linux (${version})" \
		"${bootdir}/x86_64/vmlinuz-linux" \
		"${bootdir}/x86_64/archiso.img ${bootdir}/amd_ucode.img ${bootdir}/intel_ucode.img" \
		"ip=dhcp archisobasedir=arch archiso_nfs_srv=${PXE_NFS_HOST}:${NFS_PATH}/${version} copytoram=\$SP_ARCH_COPYTORAM mirror=\$SP_ARCH_MIRROR"
done < <(ls | sort -ru)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
