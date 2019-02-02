#!/bin/bash
#menu: FreeBSD
#root: freebsd

source functions.sh
cd "${LOCAL_PATH}" || exit 1

while read -r folder; do
    IFS='_' read -r version arch <<< "${folder}"
	[[ ${arch} == "i386" ]] && grub_cpu=i386 || grub_cpu=x86_64

	cat <<- EOF
		if [ \$grub_platform != efi -o \$grub_cpu = ${grub_cpu} ]; then
		  menuentry 'FreeBSD ${version}-RELEASE (${arch})' {
		    if [ \$grub_platform = efi ]; then
		      chainloader ${GRUB_PATH}/${folder}/boot/loader_pxe.efi
		    else
		      echo "Loading kernel..."
		      kfreebsd ${GRUB_PATH}/${folder}/boot/kernel/kernel
		      kfreebsd_loadenv ${GRUB_PATH}/${folder}/boot/device.hints
		      echo "Loading rootfs image..."
		      kfreebsd_module ${GRUB_PATH}/${folder}/cd.iso type=mfs_root
		      set kFreeBSD.vfs.root.mountfrom="cd9660:/dev/md0"
		      set kFreeBSD.vfs.root.mountfrom.options=ro
		    fi
		  }
		fi
	EOF
done < <(ls | sort -t_ -k1,1r -k2)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
