#!/bin/bash
#menu: Ubuntu
#root: ubuntu

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_UBUNTU_ARCH Architecture \
	amd64 amd64 "For most modern PCs" \
	i386  i386  "For very old PCs"
grub_option SP_UBUNTU_ROOTFS "LiveCD RootFS" \
	toram ToRAM "Copy RootFS to RAM" \
	""    NFS   "Mount RootFS via NFS"

IFS=' ' read -r -a mirrors <<< "${UBUNTU_MIRROR_BACKUP}"
grub_mirror_selector SP_UBUNTU_MIRROR "${UBUNTU_MIRROR}" "${mirrors[@]}"

grub_menu_sep '--- Live CD ---'

while read -r folder; do
	IFS='_' read -r codename version variant arch <<< "${folder}"

	# Check LiveCD kernel existence
	kernels=("${folder}/casper/vmlinuz"*)
	initrds=("${folder}/casper/initrd"*)
	[[ -f "${kernels[0]}" && -f "${initrds[0]}" ]] || continue

	echo "if [ \$SP_UBUNTU_ARCH = ${arch} ]; then"
	grub_linux_entry \
		"Ubuntu ${version} (${codename}) ${variant} LiveCD" \
		"${GRUB_PATH}/${kernels[0]}" \
		"${GRUB_PATH}/${initrds[0]}" \
		"boot=casper netboot=nfs nfsroot=${PXE_NFS_HOST}:${NFS_PATH}/${folder} locale=zh_CN \${SP_UBUNTU_ROOTFS}"
	echo "fi"
done < <(ls | sort -t_ -k2,2r -k3)

grub_menu_sep '--- Network Installer ---'

fmt="(\$mirror_protocol,\$mirror_host)/\$mirror_path/dists/%s/main/installer-\${SP_UBUNTU_ARCH}/current/images/netboot/ubuntu-installer/\${SP_UBUNTU_ARCH}"
while read -r version full_version support codename; do
	[[ "${support}" == 1 ]] && lts="LTS " || lts=""

	grub_linux_entry \
		"Ubuntu ${version} ${lts}(${codename}) installer" \
		"$(printf "${fmt}" "${codename}")/linux" \
		"$(printf "${fmt}" "${codename}")/initrd.gz" \
		"url=${HTTP_PATH}/preseed.txt"
done < release-list

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
