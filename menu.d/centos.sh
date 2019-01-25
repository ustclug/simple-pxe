#!/bin/bash
#menu: CentOS
#root: centos

source functions.sh
cd "${LOCAL_PATH}" || exit 1

cat <<- EOF
	if [ -z "\$SP_CENTOS_ARCH" ]; then
	  if [ \$grub_cpu = "x86_64" ]; then
	    set SP_CENTOS_ARCH='x86_64'
	  else
	    set SP_CENTOS_ARCH='i386'
	  fi
	fi

	submenu "[option] Architecture = \$SP_CENTOS_ARCH" {
	  menuentry 'amd64: For most modern PCs' {
	    set SP_CENTOS_ARCH='x86_64'
	    export SP_CENTOS_ARCH
	    configfile ${PXE_MENU_URL}
	}
	  menuentry 'i386: For very old PCs' {
	    set SP_CENTOS_ARCH='i386'
	    export SP_CENTOS_ARCH
	    configfile ${PXE_MENU_URL}
	  }
	}
EOF

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
