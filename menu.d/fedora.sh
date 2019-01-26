#!/bin/bash
#menu: Fedora
#root: fedora

source functions.sh
cd "${LOCAL_PATH}" || exit 1

grub_menu_sep '--- Live CD ---'

while read -r folder; do
	IFS='_' read -r variant iso_type version rev <<< "${folder}"

	# Check LiveCD kernel existence
	kernels=("${folder}/isolinux/vmlinuz"*)
	initrds=("${folder}/isolinux/initrd"*)
	image="${folder}/LiveOS/squashfs.img"
	[[ -f "${kernels[0]}" && -f "${initrds[0]}" && -f "${image}" ]] || continue

	grub_linux_entry \
		"Fedora ${version} ${variant} ${iso_type}" \
		"${GRUB_PATH}/${kernels[0]}" \
		"${GRUB_PATH}/${initrds[0]}" \
		"root=live:${HTTP_PATH}/${image} ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0"
done < <( ls | sort -t_ -k3nr )

grub_menu_sep '--- Network Installer ---'

fmt="$(url2grub "${FEDORA_MIRROR}")/releases/%s/Everything/x86_64/os/images/pxeboot"
while read -r version rel; do
	grub_linux_entry \
		"Fedora ${version} installer" \
		"$(printf "${fmt}" "${version}")/vmlinuz" \
		"$(printf "${fmt}" "${version}")/initrd.img" \
		"inst.repo=${FEDORA_MIRROR}/releases/${version}/Everything/x86_64/os/"
done < release-list

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
