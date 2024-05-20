#!/bin/bash
#menu: Tools
#root: tool

source functions.sh

do_memtest() {
	cd "${LOCAL_PATH}/memtest" || return 1

	binary=$(ls memtest.efi | sort -ru | head -n1)
	if [[ -f "${binary}" ]]; then
		cat <<- EOF
			if [ \$grub_platform = efi ]; then
			  menuentry 'Memtest86+ (EFI)' {
			    echo 'Loading...'
			    chainloader ${GRUB_PATH}/memtest/${binary}
			  }
			fi
		EOF
	fi

	binary=$(ls memtest.bin | sort -ru | head -n1)
	if [[ -f "${binary}" ]]; then
		cat <<- EOF
			if [ \$grub_platform = pc ]; then
			  menuentry 'Memtest86+ (BIOS)' {
			    echo 'Loading...'
			    linux16 ${GRUB_PATH}/memtest/${binary}
			}
			fi
		EOF
	fi
}

do_uefishell() {
	cd "${PXE_LOCAL_ROOT}/archlinux" || return 1
	local latest=$(ls | sort -ru | head -n1)

	efipath="${latest}/EFI/BOOT/BOOTx64.EFI"
	if [[ -f "${efipath}" ]]; then
		relpath=$(realpath --relative-to="${PXE_LOCAL_ROOT}" "${efipath}")
		cat <<- EOF
				if [ \$grub_platform = efi ]; then
				  menuentry 'UEFI Shell' {
				    echo 'Loading...'
				    chainloader $(url2grub "${PXE_HTTP_ROOT}/${relpath}")
			    }
				fi
			EOF
	fi
}

do_memtest
do_uefishell

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
