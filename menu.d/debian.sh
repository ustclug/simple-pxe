#!/bin/bash

source functions.sh

echo "submenu 'Debian' {"

cd $DEBIAN_LOCAL_ROOT
while read version; do
	echo "submenu 'Debian $version' {"

	while read folder; do
		IFS='/' read -r -a info <<< "$folder"
		thisroot=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$folder")

		vmlinuz_path=$(grep -Pom1 '^\s*linux\s*\K\S+' $folder/boot/grub/grub.cfg)
		vmlinuz_url="$PXE_HTTP_ROOT/$thisroot/$vmlinuz_path"
		initrd_path=$(grep -Pom1 '^\s*initrd\s*\K\S+' $folder/boot/grub/grub.cfg)
		initrd_url="$PXE_HTTP_ROOT/$thisroot/$initrd_path"

		cat <<-EOF
        menuentry 'Debian ${info[0]} (${info[1]}, ${info[2]})' {
            linux $(url2grub $vmlinuz_url) boot=live components netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_NFS_ROOT/$thisroot/ locale=zh_CN
            initrd $(url2grub $initrd_url)
        }
		EOF

	done < <(find "$version" -maxdepth 2 -mindepth 2 -not -path '*/\.*' | sort -r)

	echo "}"
done < <(ls | sort -ru)

echo "}"
# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
