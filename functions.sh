#!/bin/bash

url2grub() {
	local url="$1"
	local url_regex='^(http|tftp)://([^/]+)(/.*)?$'
	if [[ "$url" =~ $url_regex ]]; then
		local protocol="${BASH_REMATCH[1]}"
		local host="${BASH_REMATCH[2]}"
		local path="${BASH_REMATCH[3]}"
		echo "($protocol,$host)/$path"
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

grep_web() {
	local url="$1"
	local regex="$2"
	curl -fsL "$url" | grep -Po "$regex" | sort -ur
}

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
