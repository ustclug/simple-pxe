#!/bin/bash
#menu: Ubuntu
#root: ubuntu

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_option SP_UBUNTU_ARCH Architecture \
	amd64 amd64 "For most modern PCs" \
	i386  i386  "For very old PCs"

IFS=' ' read -r -a mirrors <<< "${UBUNTU_MIRROR_BACKUP}"
grub_mirror_selector SP_UBUNTU_MIRROR "${UBUNTU_MIRROR}" "${mirrors[@]}"

grub_menu_sep '--- Live CD ---'

while read -r folder; do
	IFS='_' read -r codename version variant arch <<< "${folder}"

	media="${folder}/http"
	[[ -f "${media}/install.iso" && -f "${media}/casper/vmlinuz" && -f "${media}/casper/initrd" ]] || continue

	iso_url="${HTTP_PATH}/${media}/install.iso"
	iso_param="iso-url=${iso_url}"
	if [[ "${version%%.*}" -le 22 ]]; then
		iso_param="cloud-config-url=/dev/null url=${iso_url}"
	fi
	echo "if [ \$SP_UBUNTU_ARCH = ${arch} ]; then"
	grub_linux_entry \
		"Ubuntu ${version} (${codename}) ${variant} LiveCD" \
		"${GRUB_PATH}/${media}/casper/vmlinuz" \
		"${GRUB_PATH}/${media}/casper/initrd" \
		"boot=casper ip=dhcp ${iso_param} locale=zh_CN"
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
