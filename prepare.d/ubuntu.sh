#!/bin/bash

set -e

source functions.sh

current_year=$(date +%y)
iso_urls=()
iso_regex='ubuntu-([0-9.]+)-([a-z-]+)-(amd64).iso$'

for (( year = current_year; year >= 12; year-- )); do
	for ver in "${year}.10" "${year}.04"; do
		url="$UBUNTU_RELEASES_MIRROR/$ver/"
		retcode=$(curl -w %{http_code} -s -I -o/dev/null $url)
		if [[ $retcode == 404 ]]; then
			continue
		fi

		mapfile -t files < <(curl -s "${url}HEADER.html" | grep -Po '<a href="\Kubuntu-[0-9.]+-(server|desktop|live-server)-(amd64|i386).iso')
		for var in "${files[@]}"; do
			if [[ "$var" =~ $iso_regex ]]; then
				iso_urls+=("$url$var")
			fi
		done
	done
done

for url in "${iso_urls[@]}"; do
	if [[ "$url" =~ $iso_regex ]]; then
		version="${BASH_REMATCH[1]}"
		variant="${BASH_REMATCH[2]}"
		arch="${BASH_REMATCH[3]}"

		folder="$UBUNTU_LOCAL_ROOT/$version/$variant/$arch"
		tmp_folder="$UBUNTU_LOCAL_ROOT/$version/$variant/.tmp"

		if [[ -d "$folder" ]]; then
			echo "Already exists: $folder"
		else
			echo "Extracting $url to $folder"
			mkdir -p "$tmp_folder"
			curl "$url" | bsdtar -x -f - -C "$tmp_folder"
			mv "$tmp_folder" "$folder"
		fi
	fi
done
# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
