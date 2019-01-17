#!/bin/bash

set -e

source functions.sh

text=$(curl -s "$ARCHLINUX_MIRROR/iso/latest/md5sums.txt")
[[ "$text" =~ archlinux-([0-9.]+)-x86_64.iso ]]
iso_file="$BASH_REMATCH"
version="${BASH_REMATCH[1]}"

folder="$ARCHLINUX_LOCAL_ROOT/$version"
tmp_folder="$ARCHLINUX_LOCAL_ROOT/.$version"

if [[ -d "$folder" ]]; then
	echo "Already exists: $folder"
else
	mkdir -p "$tmp_folder"
	curl "$ARCHLINUX_MIRROR/iso/latest/$iso_file" \
		| bsdtar -x -f - -C "$tmp_folder"
	mv "$tmp_folder" "$folder"
fi

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
