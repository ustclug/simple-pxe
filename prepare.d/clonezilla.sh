#!/bin/bash

source functions.sh

iso_regex="clonezilla-live-([0-9]{8}-[a-z]+)-(amd64|i386).zip"

while read iso_file; do
	if [[ "$iso_file" =~ $iso_regex ]]; then
		version="${BASH_REMATCH[1]}"
		arch="${BASH_REMATCH[2]}"

		url="https://osdn.net/dl/clonezilla/$iso_file"
		url_check "$url" || continue
		target="$CLONEZILLA_LOCAL_ROOT/${version}_${arch}"

		if [[ -d "$target" ]]; then
			echo "Already exists: $target"
		else
			echo "Extracting $url to $target"
			net_extract "$url" "$target"
		fi
	fi
done < <(grep_web https://clonezilla.org/downloads/alternative/data/CHECKSUMS.TXT "$iso_regex")

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
