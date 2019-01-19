#!/bin/bash

panick () {
    local mesg=$1; shift
    local str=$(printf "==> ERROR: ${mesg}\n" "$@")
    log "$str"; echo $str >&2
    exit 1
}

url2grub() {
	local url="$1"
	local url_regex='^(http|tftp)://([^/]+)(/.*)?$'
	if [[ "$url" =~ $url_regex ]]; then
		local protocol="${BASH_REMATCH[1]}"
		local host="${BASH_REMATCH[2]}"
		local path="${BASH_REMATCH[3]}"
		echo "($protocol,$host)$path"
	fi
}

net_extract() {
	local url="$1"
	local target="$2"

	local workdir=$(dirname "$target")
	mkdir -p "$workdir"
	local tmpdir=$(mktemp -d -p "$workdir" .tmp.XXXXXXXX)
	trap "rm -rf $tmpdir/" EXIT RETURN

	curl -fsL "$url" | bsdtar -x -f - -C "$tmpdir"
	if [[ "${PIPESTATUS[0]}" == 0 ]]; then
		mv "$tmpdir" "$target"
	fi
}

url_check() {
	curl -fI "$1" >/dev/null 2>&1
}

grep_web() {
	local url="$1"
	local regex="$2"
	curl -fsL "$url" | grep -Po "$regex" | sort -ur
}

get_ubuntu_releases() {
	local mirror regex
	mirror=${UBUNTU_RELEASES_MIRROR:-http://releases.ubuntu.com/}
	regex="Ubuntu ([0-9]{2}\.[0-9]{2})(\.[0-9]+)? (LTS )?\(([A-Z][a-z]+) [A-Z][a-z]+\)" 
	while read line; do
		if [[ "$line" =~ $regex ]]; then
			version="${BASH_REMATCH[1]}"
			full_version="$version${BASH_REMATCH[2]}"
			[[ "${BASH_REMATCH[3]}" != "LTS " ]]
			support=$?
			codename="${BASH_REMATCH[4],,}"
			echo -e "$version\t$full_version\t$support\t$codename"
		fi
	done < <(curl -sL "$mirror/HEADER.html") | sort -ur
}

grub_menu_sep() {
	cat <<-EOF
	menuentry '$1' {
	    true
	}
	EOF
}

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
