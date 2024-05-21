#!/bin/bash
#root: fedora

source functions.sh
cd "${LOCAL_PATH}" || exit 1

temp[rlist]=$(mktemp)

count=0
for ((version=38; version<100; version++)); do
	url_base="${FEDORA_MIRROR}/releases/${version}"
	url_check "${url_base}/" 403 || break
	url=""

	for ((r=0; r<20; r++)); do
		rev="1.${r}"
		_url="${url_base}/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-${version}-${rev}.iso"
		url_check "${_url}" || continue
		url=${_url} && break
	done

	if [[ -n "${url}" ]]; then
		target="Workstation_Live_${version}_${rev}"

		if [[ -d "${target}" ]]; then
			echo "Already exists: ${target}"
		else
			echo "Extracting ${url} to ${target}"
			net_extract "${url}" "${target}"
		fi

		echo -e "${version}\t${rev}" >> "${temp[rlist]}"
		count=$((count + 1))
	fi
done

(("${count}" != 0)) && mv "${temp[rlist]}" "release-list"

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
