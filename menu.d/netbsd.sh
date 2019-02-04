#!/bin/bash
#menu: NetBSD
#root: netbsd

source functions.sh
cd "${LOCAL_PATH}" || exit 1

while read -r folder; do
    IFS='_' read -r version arch <<< "${folder}"

	cat <<- EOF
		menuentry 'NetBSD ${version} (${arch}): full distribution' {
		  echo "Loading kernel..."
		  knetbsd ${GRUB_PATH}/${folder}/netbsd
		  echo "Loading miniroot..."
		  knetbsd_module_elf ${GRUB_PATH}/${folder}/miniroot.kmod.gz
		}
		menuentry 'NetBSD ${version} (${arch}): installation kernel' {
		  echo "Loading kernel..."
		  knetbsd ${GRUB_PATH}/${folder}/netbsd-INSTALL.gz
		}
	EOF
done < <(ls | sort -t_ -k1,1r -k2)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
