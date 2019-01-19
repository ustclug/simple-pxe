#!/bin/bash
#menu: Debian

source functions.sh

cat <<-EOF
if [ -z "\$SP_DEBIAN_ARCH" ]; then
  if [ \$grub_cpu = "x86_64" ]; then
    set SP_DEBIAN_ARCH='amd64'
  else
    set SP_DEBIAN_ARCH='i386'
  fi
fi

submenu "[option] Architecture = \$SP_DEBIAN_ARCH" {
  menuentry 'amd64: For most modern PCs' {
    set SP_DEBIAN_ARCH='amd64'
    export SP_DEBIAN_ARCH
    configfile $PXE_MENU_URL
  }
  menuentry 'i386: For very old PCs' {
    set SP_DEBIAN_ARCH='i386'
    export SP_DEBIAN_ARCH
    configfile $PXE_MENU_URL
  }
}
EOF

fmt="$(url2grub $DEBIAN_MIRROR)/dists/%s/main/installer-\${SP_DEBIAN_ARCH}/current/images/netboot/debian-installer/\${SP_DEBIAN_ARCH}"
for version in stable testing unstable oldstable oldoldstable; do
	cat <<-EOF
	menuentry 'Debian $version installer' {
	  echo 'Loading kernel...'
	  linux $(printf "$fmt" $version)/linux
	  echo 'Loading initial ramdisk...'
	  initrd $(printf "$fmt" $version)/initrd.gz
	}
	EOF
done

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
