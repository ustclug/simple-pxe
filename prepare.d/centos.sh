#!/bin/bash
#root: centos

source functions.sh
cd "${LOCAL_PATH}" || exit 1

temp[rlist]=$(mktemp)

count=0
for ((version=6; ; version++)); do
	curl -fsLI -o/dev/null "${CENTOS_MIRROR}/${version}" || break

	for arch in i386 x86_64; do
		url_base="${CENTOS_MIRROR}/${version}/os/${arch}"
		tag=$(curl -fsL "${url_base}/CentOS_BuildTag") || continue
		echo -e "${version}\t${arch}\t${tag}" >> "${temp[rlist]}"
		count=$((count + 1))
	done
done

(("${count}" != 0)) && mv "${temp[rlist]}" "release-list"

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
