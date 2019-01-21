#!/bin/bash
#menu: Tools

source functions.sh

do_memtest() {
	cd "$TOOL_LOCAL_ROOT/memtest"

	memtest86plus_regex="memtest86\+-([0-9.]+)\.bin"
	memtest86_regex="memtest86_${version}_x64.efi"

	relpath=$(realpath --relative-to="$PXE_LOCAL_ROOT" .)
	wwwroot=$(url2grub "$PXE_HTTP_ROOT/$relpath")

	binary=$(ls memtest86_*_x64.efi | sort -ru | head -n1)
	if [[ -n "$binary" ]]; then
		cat <<-EOF
		if [ \$grub_platform = efi ]; then
		  menuentry 'Memtest86 (proprietary software)' {
		    echo 'Loading...'
		    chainloader $wwwroot/$binary
		  }
		fi
		EOF
	fi

	binary=$(ls memtest86plus_*.bin | sort -ru | head -n1)
	if [[ -n "$binary" ]]; then
		cat <<-EOF
		if [ \$grub_platform = pc ]; then
		  menuentry 'Memtest86+' {
		    echo 'Loading...'
		    linux16 $wwwroot/$binary
		  }
		fi
		EOF
	fi
}

do_uefishell() {
	local latest v1path v2path
	latest=$(ls "$ARCHLINUX_LOCAL_ROOT" | sort -ru)
	for ver in v2 v1; do
		efipath="$ARCHLINUX_LOCAL_ROOT/$latest/EFI/shellx64_$ver.efi"
		if [[ -f "$efipath" ]]; then
			relpath=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$efipath")
			cat <<-EOF
			if [ \$grub_platform = efi ]; then
			  menuentry 'UEFI Shell ($ver)' {
			    echo 'Loading...'
			    chainloader $(url2grub "$PXE_HTTP_ROOT/$relpath")
			  }
			fi
			EOF
		fi
	done
}

do_memtest
do_uefishell

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
