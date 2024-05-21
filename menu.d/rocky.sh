#!/bin/bash
#menu: Rocky
#root: rocky

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_ROCKY_ARCH Architecture \
	x86_64 x86_64 "For most modern PCs"

IFS=' ' read -r -a mirrors <<< "${ROCKY_MIRROR_BACKUP}"
grub_mirror_selector SP_ROCKY_MIRROR "${ROCKY_MIRROR}" "${mirrors[@]}"

while read -r version arch; do
	base="(\$mirror_protocol,\$mirror_host)/\$mirror_path/${version}/BaseOS/${arch}/os/images/pxeboot"
	repo_arg="inst.repo"

	echo "if [ \$SP_ROCKY_ARCH = ${arch} ]; then"
	grub_linux_entry \
		"Rocky ${version} Installer" \
		"${base}/vmlinuz" \
		"${base}/initrd.img" \
		"${repo_arg}=\$SP_ROCKY_MIRROR/${version}/BaseOS/${arch}/os"
	echo "fi"
done < <(tac release-list)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
