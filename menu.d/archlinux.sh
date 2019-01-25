#!/bin/bash
#menu: Arch Linux
#root: archlinux

source functions.sh
cd "${LOCAL_PATH}" || exit 1

cat <<- EOF
	if [ -z "\$SP_ARCH_COPYTORAM" ]; then
	  set SP_ARCH_COPYTORAM='y'
	fi

	submenu "[option] Copy RootFS to RAM = \$SP_ARCH_COPYTORAM" {
	  menuentry 'y: Copy RootFS to RAM' {
	    set SP_ARCH_COPYTORAM='y'
	    export SP_ARCH_COPYTORAM
	    configfile ${PXE_MENU_URL}
	  }
	  menuentry 'n: Mount RootFS via NFS' {
	    set SP_ARCH_COPYTORAM='n'
	    export SP_ARCH_COPYTORAM
	    configfile ${PXE_MENU_URL}
	  }
	}
EOF

while read -r version; do
	bootdir="${GRUB_PATH}/${version}/arch/boot"
	grub_linux_entry \
		"Arch Linux (${version})" \
		"${bootdir}/x86_64/vmlinuz" \
		"${bootdir}/x86_64/archiso.img ${bootdir}/amd_ucode.img ${bootdir}/intel_ucode.img" \
		"ip=dhcp archisobasedir=arch archiso_nfs_srv=${PXE_NFS_HOST}:${NFS_PATH}/${version} copytoram=\$SP_ARCH_COPYTORAM mirror=${ARCHLINUX_MIRROR}"
done < <(ls | sort -ru)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
