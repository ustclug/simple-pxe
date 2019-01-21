#!/bin/bash

set -e
source functions.sh

workdir="$TOOL_LOCAL_ROOT/memtest/"
mkdir -p "$workdir"

# Memtest86+, FOSS, but not UEFI-compatible
url_base="http://www.memtest.org"
url_regex='download/[0-9.]+/memtest86\+-([0-9.]+)\.bin\.gz'
output=$(curl -sfL "$url_base" | grep -Eom1 "$url_regex")
if [[ "$output" =~ $url_regex ]]; then
	version="${BASH_REMATCH[1]}"
	target="$workdir/memtest86plus_${version}.bin"
	url="$url_base/$output"

	if [[ -f "$target" ]]; then
		echo "Already exists: $target"
	else
		echo "Extracting $url to $target"

		tmp="$workdir/.tmp.memtest86plus"
		trap "rm -f $tmp" EXIT

		curl -fsL "$url" | gzip -d > "$tmp"

		if [[ "${PIPESTATUS[0]}" == 0 && "$?" == 0 ]]; then
			mv "$tmp" "$target"
		else
			echo "Download failed"
			rm -f "$tmp"
		fi
	fi
fi

# Memtest86, not FOSS, we only fetch UEFI image
url_base="https://www.memtest86.com/"
while read line; do
	if [[ "$line" =~ MemTest86\ (v[0-9.]+)\ Free ]]; then
		version="${BASH_REMATCH[1]}"
		target="$workdir/memtest86_${version}_x64.efi"

		if [[ -f "$target" ]]; then
			echo "Already exists: $target"
		else
			folder="$workdir/.tmp.memtest86"
			url="$url_base/downloads/memtest86-usb.zip"
			echo "Extracting $url to $folder"
			net_extract "$url_base/downloads/memtest86-usb.zip" "$folder"

			trap "rm -rf $folder" EXIT
			stderr=$(fatcat -O 1048576 "$folder/memtest86-usb.img" -r /EFI/BOOT/BOOTX64.efi 2>&1 > "$folder/bootx64.efi")

			if [[ -n "$stderr" ]]; then
				echo "Error when extract memtest86 image:"
				echo $stderr
			else
				mv "$folder/bootx64.efi" "$target"
			fi
		fi

		break
	fi
done < <(curl -sfL "$url_base/download.htm")

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
