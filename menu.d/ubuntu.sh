#!/bin/bash
#menu: Ubuntu

source functions.sh

cat <<-EOF
if [ -z "\$SP_UBUNTU_ARCH" ]; then
  if [ \$grub_cpu = "x86_64" ]; then
    set SP_UBUNTU_ARCH='amd64'
  else
    set SP_UBUNTU_ARCH='i386'
  fi
fi

if [ -z "\$SP_UBUNTU_ROOTFS" ]; then
  set SP_UBUNTU_ROOTFS='toram'
fi

submenu "[option] Architecture = \$SP_UBUNTU_ARCH" {
  menuentry 'amd64: For most modern PCs' {
    set SP_UBUNTU_ARCH='amd64'
    export SP_UBUNTU_ARCH
    configfile $PXE_MENU_URL
  }
  menuentry 'i386: For very old PCs' {
    set SP_UBUNTU_ARCH='i386'
    export SP_UBUNTU_ARCH
    configfile $PXE_MENU_URL
  }
}

submenu "[option] LiveCD RootFS = \$SP_UBUNTU_ROOTFS" {
  menuentry 'toram: Copy RootFS to RAM' {
    set SP_UBUNTU_ROOTFS='toram'
    export SP_UBUNTU_ROOTFS
    configfile $PXE_MENU_URL
  }
  menuentry 'network_mount: Mount RootFS via NFS' {
    set SP_UBUNTU_ROOTFS='network_mount'
    export SP_UBUNTU_ROOTFS
    configfile $PXE_MENU_URL
  }
}
EOF

grub_menu_sep '--- Network Installer ---'

fmt="$(url2grub $UBUNTU_MIRROR)/dists/%s/main/installer-\${SP_UBUNTU_ARCH}/current/images/netboot/ubuntu-installer/\${SP_UBUNTU_ARCH}"
while read version full_version support codename; do
	[[ $support = 1 ]] && lts="LTS " || lts=""

	cat <<-EOF
	menuentry 'Ubuntu ${version} ${lts}(${codename}) installer' {
	  echo 'Loading kernel...'
	  linux $(printf "$fmt" $codename)/linux
	  echo 'Loading initial ramdisk...'
	  initrd $(printf "$fmt" $codename)/initrd.gz
	}
	EOF
done < <(get_ubuntu_releases)

grub_menu_sep '--- Live CD ---'
cd $UBUNTU_LOCAL_ROOT
while read folder; do
	IFS='_' read codename version variant arch <<< "$folder"

	kernel=$(ls "$folder/casper/" | grep -Pom1 '^vmlinuz(\.\w+)?$' || true)
	initrd=$(ls "$folder/casper/" | grep -Pom1 '^initrd(\.\w+)?$' || true)
	[[ -z "$kernel" || -z "$initrd" ]] && continue

	relpath=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$folder")
	wwwroot=$(url2grub "$PXE_HTTP_ROOT/$relpath")

	cat <<-EOF
	if [ "\$SP_UBUNTU_ARCH" = "$arch" ]; then
	menuentry 'Ubuntu $version ($codename) $variant LiveCD' {
	  echo 'Loading kernel...'
	  linux $wwwroot/casper/$kernel boot=casper netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_NFS_ROOT/$relpath/ locale=zh_CN \${SP_UBUNTU_ROOTFS}
	  echo 'Loading initial ramdisk...'
	  initrd $wwwroot/casper/$initrd
	}
	fi
	EOF
done < <(ls | sort -t_ -k2,2r -k3)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
