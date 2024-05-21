#!/bin/bash
#root: rocky

source functions.sh
cd "${LOCAL_PATH}" || exit 1

temp[rlist]=$(mktemp)

count=0
for ((version=8; version<20; version++)); do
	url_check "${ROCKY_MIRROR}/${version}" 403 || break

	for arch in i386 x86_64; do
		url_base="${ROCKY_MIRROR}/${version}/os/${arch}"
		echo -e "${version}\t${arch}" >> "${temp[rlist]}"
		count=$((count + 1))
	done
done

(("${count}" != 0)) && mv "${temp[rlist]}" "release-list"

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
