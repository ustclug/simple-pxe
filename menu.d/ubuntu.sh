#!/bin/bash
#menu: Ubuntu

source functions.sh

cd $UBUNTU_LOCAL_ROOT
while read version; do
	echo "submenu 'Ubuntu $version' {"

	while read folder; do
		if [[ ! -d "$folder/casper" ]]; then
			continue
		fi

		IFS='/' read -r -a info <<< "$folder"

		relpath=$(realpath --relative-to="$PXE_LOCAL_ROOT" "$folder")
		wwwroot=$(url2grub "$PXE_HTTP_ROOT/$relpath")

		codename=$(readlink $folder/dists/stable)
		initrd_file=$(ls "$folder/casper/" | grep -Pom1 '^initrd(\.\w+)?$')
		kernel_file=$(ls "$folder/casper/" | grep -Pom1 '^vmlinuz(\.\w+)?$')

		cat <<-EOF
		  menuentry 'Ubuntu ${info[0]} ${info[1]} (${info[2]})' {
		    echo 'Loading kernel...'
		    linux $wwwroot/casper/$kernel_file boot=casper netboot=nfs nfsroot=$PXE_NFS_HOST:$PXE_NFS_ROOT/$relpath/ locale=zh_CN toram
		    echo 'Loading initial ramdisk...'
		    initrd $wwwroot/casper/$initrd_file
		  }
		EOF
	done < <(find "$version"* -maxdepth 2 -mindepth 2 -not -path '*/\.*' | sort -r)

	if [[ -n "$UBUNTU_MIRROR" && -n "$codename" ]]; then
		for arch in amd64 i386; do
			base_url=$(url2grub "$UBUNTU_MIRROR/dists/$codename/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch")
			cat <<-EOF
			  menuentry 'Ubuntu $version Installer ($arch)' {
			    echo 'Loading kernel...'
			    linux ${base_url}/linux
			    echo 'Loading initial ramdisk...'
			    initrd ${base_url}/initrd.gz
			  }
			EOF
		done
	fi

	echo "}"
done < <(ls | grep -Po '^\d+.\d+' | sort -ru)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
