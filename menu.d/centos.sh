#!/bin/bash
#menu: CentOS
#root: centos

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_CENTOS_ARCH Architecture \
	x86_64  x86_64 "For most modern PCs" \
	i386    i386  "For very old PCs" \
	aarch64 aarch64 "For ARM64 / AARCH64 devices"

IFS=' ' read -r -a mirrors <<< "${CENTOS_MIRROR_BACKUP}"
grub_mirror_selector SP_CENTOS_MIRROR "${CENTOS_MIRROR}" "${mirrors[@]}"

while read -r version arch tag; do
	base="(\$mirror_protocol,\$mirror_host)/\$mirror_path/${version}/os/${arch}/images/pxeboot"
	(("$version" >= 7 )) && repo_arg="inst.repo" || repo_arg="repo"

	echo "if [ \$SP_CENTOS_ARCH = ${arch} ]; then"
	grub_linux_entry \
		"CentOS ${version} Installer" \
		"${base}/vmlinuz" \
		"${base}/initrd.img" \
		"${repo_arg}=\$SP_CENTOS_MIRROR/${version}/os/${arch}"
	echo "fi"
done < <(tac release-list)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
