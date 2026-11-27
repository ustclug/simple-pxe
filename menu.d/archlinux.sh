#!/bin/bash
#menu: Arch Linux
#root: archlinux

source functions.sh
cd "${LOCAL_PATH}" || exit 1

IFS=' ' read -r -a mirrors <<< "${ARCHLINUX_MIRROR_BACKUP}"
grub_mirror_selector SP_ARCH_MIRROR "${ARCHLINUX_MIRROR}" "${mirrors[@]}"

while read -r version; do
	bootdir="${version}/arch/boot"
	[[ -f "${bootdir}/x86_64/vmlinuz-linux" && -f "${bootdir}/x86_64/initramfs-linux.img" ]] || continue
	initrds=()
	for microcode in "${bootdir}"/*-ucode.img; do
		[[ -f "${microcode}" ]] && initrds+=("${GRUB_PATH}/${microcode}")
	done
	initrds+=("${GRUB_PATH}/${bootdir}/x86_64/initramfs-linux.img")
	grub_linux_entry \
		"Arch Linux (${version})" \
		"${GRUB_PATH}/${bootdir}/x86_64/vmlinuz-linux" \
		"${initrds[*]}" \
		"ip=dhcp BOOTIF=\${net_default_mac} archisobasedir=arch archiso_http_srv=${HTTP_PATH}/${version}/ mirror=\$SP_ARCH_MIRROR"
done < <(ls | sort -ru)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
