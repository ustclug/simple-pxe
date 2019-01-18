#!/bin/bash

set -e
source functions.sh

iso_regex='ubuntu-([0-9.]+)-([a-z-]+)-(amd64|i386).iso$'

while read rver; do
	iso_url_base="$UBUNTU_RELEASES_MIRROR/$rver"

	while read iso_file; do
		if [[ "$iso_file" =~ $iso_regex ]]; then
			version="${BASH_REMATCH[1]}"
			variant="${BASH_REMATCH[2]}"
			arch="${BASH_REMATCH[3]}"

			url="$iso_url_base/$iso_file"
			folder="$UBUNTU_LOCAL_ROOT/$version/$variant/$arch"

			if [[ -d "$folder" ]]; then
				echo "Already exists: $folder"
			else
				echo "Extracting $url to $folder"
				net_extract "$url" "$folder"
			fi
		fi
	done < <(grep_web "$iso_url_base/MD5SUMS" "$iso_regex")
done < <(grep_web "$UBUNTU_RELEASES_MIRROR/HEADER.html" 'Ubuntu \K[0-9]{2}.(04|10)')

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
