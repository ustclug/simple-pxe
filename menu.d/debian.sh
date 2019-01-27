#!/bin/bash
#menu: Debian
#root: debian

source functions.sh
cd "${LOCAL_PATH}" || exit 1

cat <<- EOF
	if [ -z "\$SP_DEBIAN_ARCH" ]; then
	  set SP_DEBIAN_ARCH='amd64'
	fi

	submenu "[option] Architecture = \$SP_DEBIAN_ARCH" {
	  menuentry 'amd64: For most modern PCs' {
	    set SP_DEBIAN_ARCH='amd64'
	    export SP_DEBIAN_ARCH
	    configfile ${PXE_MENU_URL}
	}
	  menuentry 'i386: For very old PCs' {
	    set SP_DEBIAN_ARCH='i386'
	    export SP_DEBIAN_ARCH
	    configfile ${PXE_MENU_URL}
	  }
	}
EOF

fmt="$(url2grub "${DEBIAN_MIRROR}")/dists/%s/main/installer-\${SP_DEBIAN_ARCH}/current/images/netboot/debian-installer/\${SP_DEBIAN_ARCH}"
while read -r codename status version; do
	grub_linux_entry \
		"Debian ${codename} (${status}) Installer" \
		"$(printf "${fmt}" "${codename}")/linux" \
		"$(printf "${fmt}" "${codename}")/initrd.gz" \
		"url=${HTTP_PATH}/preseed.txt"
done < <(sort -k3,3nr -k2,2 release-list)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
