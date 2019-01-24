#!/bin/bash
#root: archlinux

source functions.sh
cd "$LOCAL_PATH"

text=$(curl -s "${ARCHLINUX_MIRROR}/iso/latest/md5sums.txt")

if [[ "$text" =~ archlinux-([0-9.]+)-x86_64.iso ]]; then
	iso_file="${BASH_REMATCH[0]}"
	folder="${BASH_REMATCH[1]}"
	url="${ARCHLINUX_MIRROR}/iso/latest/${iso_file}"

	if [[ -d "${folder}" ]]; then
		echo "Already exists: $folder"
	else
		echo "Extracting $url to $folder"
		net_extract "$url" "$folder"
	fi
fi

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
