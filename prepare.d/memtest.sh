#!/bin/bash
#root: tool/memtest

source functions.sh
cd "$LOCAL_PATH"

# Memtest86+, FOSS, but not UEFI-compatible
url_base="http://www.memtest.org"
url_regex='download/[0-9.]+/memtest86\+-([0-9.]+)\.bin\.gz'
output=$(curl -sfL "$url_base" | grep -Eom1 "$url_regex")
if [[ "$output" =~ $url_regex ]]; then
	version="${BASH_REMATCH[1]}"
	target="memtest86plus_${version}.bin"
	url="$url_base/$output"

	if [[ -f "$target" ]]; then
		echo "Already exists: $target"
	else
		echo "Extracting $url to $target"

		temp[m86p]=".tmp.memtest86plus"
		curl -fsL "${url}" | gzip -d > "${temp[m86p]}"

		if [[ "${PIPESTATUS[0]}" == 0 && "$?" == 0 ]]; then
			mv "${temp[m86p]}" "${target}"
		else
			echo "Download failed"
			rm -f "${temp[m86p]}"
		fi
	fi
fi

# Memtest86, not FOSS, we only fetch UEFI image
url_base="https://www.memtest86.com/"
ver_regex='MemTest86 \Kv[0-9.]+(?! Free)'
version=$(curl -sfL "$url_base/download.htm" | grep -Pom1 "$ver_regex")
if [[ -n "$version" ]]; then
	target="memtest86_${version}_x64.efi"
	temp[m86]=".tmp.memtest86"

	if [[ -f "$target" ]]; then
		echo "Already exists: $target"
	else
		temp[m86]=".tmp.memtest86"
		url="$url_base/downloads/memtest86-usb.zip"

		echo "Extracting ${url} to ${temp[m86]}"
		net_extract "${url}" "${temp[m86]}"

		stderr=$(fatcat -O 1048576 "${temp[m86]}/memtest86-usb.img" \
			-r /EFI/BOOT/BOOTX64.efi 2>&1 > "${temp[m86]}/bootx64.efi")

		if [[ -n "$stderr" ]]; then
			echo "Error when extract memtest86 image:"
			echo "${stderr}"
		else
			mv "${temp[m86]}/bootx64.efi" "${target}"
		fi
	fi
fi

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
