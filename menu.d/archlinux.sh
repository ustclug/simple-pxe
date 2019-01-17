#!/bin/bash

source functions.sh

echo "submenu 'Arch Linux' {"

cd $ARCHLINUX_LOCAL_ROOT
while read version; do
	thisroot=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$version")
	vmlinuz_url="$PXE_HTTP_ROOT/$thisroot/arch/boot/x86_64/vmlinuz"
	initrd_url="$PXE_HTTP_ROOT/$thisroot/arch/boot/x86_64/archiso.img"
	amd_ucode_url="$PXE_HTTP_ROOT/$thisroot/arch/boot/amd_ucode.img"
	intel_ucode_url="$PXE_HTTP_ROOT/$thisroot/arch/boot/intel_ucode.img"

	cat <<-EOF
    menuentry 'Arch Linux ($version)' {
        linux $(url2grub $vmlinuz_url) ip=dhcp archisobasedir=arch archiso_nfs_srv=$PXE_NFS_HOST:$PXE_NFS_ROOT/$thisroot
        initrd $(url2grub $initrd_url) $(url2grub $amd_ucode_url) $(url2grub $intel_ucode_url)
    }
	EOF
done < <(ls | sort)

echo "}"
# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
