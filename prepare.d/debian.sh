#!/bin/bash

set -e
source functions.sh

iso_regex='debian-live-([0-9.]+)-(amd64|i386)-([a-z]+).iso$'

for arch in amd64 i386; do
	iso_url_base="$DEBIAN_CD_MIRROR/current-live/$arch/iso-hybrid"

	while read iso_file; do
		if [[ "$iso_file" =~ $iso_regex ]]; then
			version="${BASH_REMATCH[1]}"
			variant="${BASH_REMATCH[3]}"

			url="$iso_url_base/$iso_file"
			folder="$DEBIAN_LOCAL_ROOT/$version/$arch/$variant"

			if [[ -d "$folder" ]]; then
				echo "Already exists: $folder"
			else
				echo "Extracting $url to $folder"
				net_extract "$url" "$folder"
			fi
		fi
	done < <(grep_web "$iso_url_base/MD5SUMS" "$iso_regex")
done

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
