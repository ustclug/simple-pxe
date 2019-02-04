#!/bin/bash
#root: freebsd

source functions.sh
cd "${LOCAL_PATH}" || exit 1

count=0
while read -r ver; do
	for arch in amd64 i386; do
		url="${FREEBSD_MIRROR}/releases/ISO-IMAGES/${ver}/FreeBSD-${ver}-RELEASE-${arch}-disc1.iso"
		url_check "${url}" || continue
		target="${ver}_${arch}"

		if [[ -d "${target}" ]]; then
			echo "Already exists: ${target}"
		else
			echo "Extracting ${url} to ${target}"

			id="freebsd_${RANDOM}"
			temp[${id}]=".tmp.${target}"
			(
				set -eo pipefail

				relpath=$(realpath --relative-to="${PXE_LOCAL_ROOT}" "${target}")
				mkdir "${temp[${id}]}" && cd "${temp[${id}]}"

				curl -fsL "${url}" -o "cd.iso"
				bsdtar -x -f "cd.iso" --exclude='usr/' && mkdir usr

				efi_loader="boot/loader.efi"
				pxe_loader="boot/loader_pxe.efi"
				install -m644 "${efi_loader}" "${pxe_loader}"

				true > etc/fstab
				cat >> etc/rc.initdiskless <<- EOF
					mount -t tmpfs tmpfs /mnt
					mkdir /mnt/iso
					mount -t cd9660 /dev/\`mdconfig -f /cd.iso\` /mnt/iso
					for path in bin lib libexec root sbin usr; do
					  mount -t nullfs /mnt/iso/\$path /\$path
					done
					for path in etc var; do
					  eval md_size_\$path=32768
					  create_md \$path
					  cp -Rp /mnt/iso/\$path/ /\$path
					done
					true > /etc/fstab
				EOF

				mapfile -t loc < <(grep -obUaP "\x2f\x00{127}" "${efi_loader}" | cut -d: -f1)
				(( ${#loc[@]} == 1 ))

				printf '%s\x00' "${PXE_NFS_ROOT}/${relpath}" \
					| dd of="${pxe_loader}" bs=1 seek="${loc[0]}" conv=notrunc
			)
			[[ $? == 0 ]] && mv "${temp[${id}]}" "${target}"
		fi
	done

	count=$((count+1))
	[[ "${count}" -ge 2 ]] && break
done < <(svn ls https://svn.freebsd.org/base/releng/ | grep -Po '^\d+\.\d+(?=/$)' | sort -Vr)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
