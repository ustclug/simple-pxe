#!/bin/bash
#menu: Ubuntu
#root: ubuntu

source functions.sh
cd "$LOCAL_PATH"

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

grub_menu_sep '--- Live CD ---'

while read folder; do
	IFS='_' read codename version variant arch <<< "$folder"

	# Check LiveCD kernel existence
	kernels=( "$folder/casper/vmlinuz"* )
	initrds=( "$folder/casper/initrd"* )
	[[ -f "${kernels[0]}" && -f "${initrds[0]}" ]] || continue

	echo "if [ "\$SP_UBUNTU_ARCH" = "$arch" ]; then"
	grub_linux_entry \
		"Ubuntu $version ($codename) $variant LiveCD" \
		"$GRUB_PATH/${kernels[0]}" \
		"$GRUB_PATH/${initrds[0]}" \
		"boot=casper netboot=nfs nfsroot=$PXE_NFS_HOST:$NFS_PATH/$folder locale=zh_CN \${SP_UBUNTU_ROOTFS}"
done < <(ls | sort -t_ -k2,2r -k3)

grub_menu_sep '--- Network Installer ---'

fmt="$(url2grub $UBUNTU_MIRROR)/dists/%s/main/installer-\${SP_UBUNTU_ARCH}/current/images/netboot/ubuntu-installer/\${SP_UBUNTU_ARCH}"
while read version full_version support codename; do
	[[ "$support" == 1 ]] && lts="LTS " || lts=""

	grub_linux_entry \
		"Ubuntu ${version} ${lts}(${codename}) installer" \
		"$(printf "$fmt" $codename)/linux" \
		"$(printf "$fmt" $codename)/initrd.gz"
done < release-list

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
