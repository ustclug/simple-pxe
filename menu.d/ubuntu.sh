#!/bin/bash

source functions.sh

echo "submenu 'Ubuntu' {"

cd $UBUNTU_LOCAL_ROOT
ls | grep -Po '^\d+.\d+' | sort -ru | while read version; do
echo "submenu 'Ubuntu $version' {"

while read folder; do
	IFS='/' read -r -a info <<< "$folder"
	thisroot=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$folder")
	codename=$(readlink $folder/dists/stable)

	vmlinuz_path=$(grep -Pom1 '^\s*linux\s*\K\S+' $folder/boot/grub/grub.cfg)
	vmlinuz_url="$PXE_HTTP_ROOT/$thisroot/$vmlinuz_path"
	initrd_path=$(grep -Pom1 '^\s*initrd\s*\K\S+' $folder/boot/grub/grub.cfg)
	initrd_url="$PXE_HTTP_ROOT/$thisroot/$initrd_path"

	cat <<-EOF
    menuentry 'Ubuntu ${info[0]} ${info[1]} (${info[2]})' {
        linux $(url2grub $vmlinuz_url) boot=casper netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_NFS_ROOT/$thisroot/ locale=zh_CN systemd.mask=tmp.mount
        initrd $(url2grub $initrd_url)
    }
	EOF
done < <(find "$version"* -maxdepth 2 -mindepth 2 -not -path '*/\.*' | sort -r)

if [[ -n "$UBUNTU_MIRROR" && -n "$codename" ]]; then
	for arch in amd64 i386; do
		vmlinuz_url="$UBUNTU_MIRROR/dists/$codename/main/installer-$arch/current/images/netboot/ubuntu-installer/amd64/linux"
		initrd_url="$UBUNTU_MIRROR/dists/$codename/main/installer-$arch/current/images/netboot/ubuntu-installer/amd64/initrd.gz"
		cat <<-EOF
    menuentry 'Ubuntu $version Installer ($arch)' {
        linux $(url2grub $vmlinuz_url)
        initrd $(url2grub $initrd_url)
    }
		EOF
	done
fi

echo "}"
done

echo "}"
# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
