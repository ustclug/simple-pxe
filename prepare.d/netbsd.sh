#!/bin/bash
#root: netbsd

source functions.sh
cd "${LOCAL_PATH}" || exit 1

last_major_ver=100
while read -r ver; do
	major_ver=${ver%%.*}

	#(( major_ver < 8 )) && break
	(( major_ver < last_major_ver )) \
		&& last_major_ver="${major_ver}" \
		|| continue

	for arch in amd64 i386; do
		url="${NETBSD_MIRROR}/images/${ver}/NetBSD-${ver}-${arch}.iso"
		url_check "${url}" || continue
		target="${ver}_${arch}"

		if [[ -d "${target}" ]]; then
			echo "Already exists: ${target}"
		else
			echo "Extracting ${url} to ${target}"

			id="netbsd_${RANDOM}"
			temp[${id}]=".tmp.${target}"
			(
				set -eo pipefail

				relpath=$(realpath --relative-to="${PXE_LOCAL_ROOT}" "${target}")
				mkdir "${temp[${id}]}" && cd "${temp[${id}]}"
				curl -fsL "${url}" -o "cd.iso"

				# Generate miniroot
				mkdir miniroot
				bsdtar -C miniroot -xf cd.iso \
					"netbsd" "${arch}/" "dev/MAKEDEV"
				bsdtar -C miniroot -xf "miniroot/${arch}/binary/sets/base.tgz" rescue/
				mkdir miniroot/{etc,tmp,var}
				mv "miniroot/${arch}/binary/kernel/netbsd-INSTALL.gz" .
				mv "miniroot/netbsd" .

				zcat "miniroot/${arch}/installation/miniroot/miniroot.kmod" > miniroot.kmod
				rm -rf "miniroot/${arch}"
				objcopy miniroot.kmod --dump-section miniroot=miniroot/miniroot.fs
				bzip2 -k --best miniroot/miniroot.fs

				echo "nfs_path=\"${PXE_NFS_HOST}:${PXE_NFS_ROOT}/${relpath}\"" >> miniroot/etc/rc
				sed -e 's/#.*$//' -e '/^$/d' "${ASSET_PATH}/rc.miniroot" >> miniroot/etc/rc

				genisoimage -o miniroot.iso -JR miniroot/
				objcopy --update-section miniroot=miniroot.iso miniroot.kmod
				gzip --best miniroot.kmod

				rm miniroot.iso
				rm -rf miniroot/
			)
			[[ $? == 0 ]] && mv "${temp[${id}]}" "${target}"
		fi
	done
done < <(grep_web "${NETBSD_MIRROR}/README" '^NetBSD-\K[0-9.]+')

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
