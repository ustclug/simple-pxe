#!/bin/bash
#menu: CentOS
#root: centos

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_CENTOS_ARCH Architecture \
	x86_64 x86_64 "For most modern PCs" \
	i386   i386  "For very old PCs"

while read -r version arch tag; do
	base="$(url2grub "${CENTOS_MIRROR}")/${version}/os/${arch}/images/pxeboot"
	(("$version" >= 7 )) && repo_arg="inst.repo" || repo_arg="repo"

	echo "if [ \$SP_CENTOS_ARCH = ${arch} ]; then"
	grub_linux_entry \
		"CentOS ${version} Installer" \
		"${base}/vmlinuz" \
		"${base}/initrd.img" \
		"${repo_arg}=${CENTOS_MIRROR}/${version}/os/${arch}"
	echo "fi"
done < <(tac release-list)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
