#!/bin/bash

source functions.sh

while read version full_version support codename; do
	for arch in amd64 i386; do
		for variant in desktop live-server; do
			iso="ubuntu-${full_version}-${variant}-${arch}.iso"
			url="$UBUNTU_RELEASES_MIRROR/$version/$iso"
			target="${UBUNTU_LOCAL_ROOT}/${codename}_${full_version}_${variant}_${arch}"

			url_check "$url" || continue

			if [[ -d "$target" ]]; then
				echo "Already exists: $target"
			else
				echo "Extracting $url to $target"
				net_extract "$url" "$target"
			fi
		done
	done
done < <(get_ubuntu_releases)

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
