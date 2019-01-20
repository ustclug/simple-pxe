#!/bin/bash

source functions.sh

join_by() { local IFS="$1"; shift; echo "$*"; }

prepare() {
	local local_root="$1"
	local file_regex="$2"
	local mirror_url="$3"
	local filelist_url="$4"

	while read filename; do
		if [[ "$filename" =~ $file_regex ]]; then
			url="$mirror_url/$filename"
			url_check "$url" || continue
			target="$local_root/$(join_by _ "${BASH_REMATCH[@]:1}")"

			if [[ -d "$target" ]]; then
				echo "Already exists: $target"
			else
				echo "Extracting $url to $target"
				net_extract "$url" "$target"
			fi
		fi
	done < <(grep_web "$filelist_url" "$file_regex")
}

case "$(basename $0)" in
	clonezilla.sh)
		prepare "$CLONEZILLA_LOCAL_ROOT" \
			"clonezilla-live-([0-9]{8}-[a-z]+)-(amd64|i386).zip" \
			"https://osdn.net/dl/clonezilla" \
			"https://clonezilla.org/downloads/alternative/data/CHECKSUMS.TXT" \
		;;
	gparted.sh)
		prepare "$GPARTED_LOCAL_ROOT" \
			"gparted-live-([0-9.]+-[0-9]+)-(amd64|i686|i686-pae).zip" \
			"https://downloads.sourceforge.net/gparted" \
			"https://gparted.org/gparted-live/stable/CHECKSUMS.TXT" \
		;;
	*)
		panick 'Unknown repo!'
esac

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
