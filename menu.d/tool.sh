#!/bin/bash
#menu: Tools
#root: tool

source functions.sh

do_memtest() {
	cd "${LOCAL_PATH}/memtest" || return 1

	binary=$(ls memtest86_*_x64.efi | sort -ru | head -n1)
	if [[ -f "${binary}" ]]; then
		cat <<- EOF
			if [ \$grub_platform = efi ]; then
			  menuentry 'Memtest86 (proprietary software)' {
			    echo 'Loading...'
			    chainloader ${GRUB_PATH}/memtest/${binary}
			  }
			fi
		EOF
	fi

	binary=$(ls memtest86plus_*.bin | sort -ru | head -n1)
	if [[ -f "${binary}" ]]; then
		cat <<- EOF
			if [ \$grub_platform = pc ]; then
			  menuentry 'Memtest86+' {
			    echo 'Loading...'
			    linux16 ${GRUB_PATH}/memtest/${binary}
			}
			fi
		EOF
	fi
}

do_uefishell() {
	cd "${PXE_LOCAL_ROOT}/archlinux" || return 1
	local latest=$(ls | sort -ru)

	for ver in v2 v1; do
		efipath="${latest}/EFI/shellx64_${ver}.efi"
		if [[ -f "${efipath}" ]]; then
			relpath=$(realpath --relative-to="${PXE_LOCAL_ROOT}" "${efipath}")
			cat <<- EOF
				if [ \$grub_platform = efi ]; then
				  menuentry 'UEFI Shell (${ver})' {
				    echo 'Loading...'
				    chainloader $(url2grub "${PXE_HTTP_ROOT}/${relpath}")
				  }
				fi
			EOF
		fi
	done
}

do_memtest
do_uefishell

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
