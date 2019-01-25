#!/bin/bash
#root: ubuntu

source functions.sh
cd "${LOCAL_PATH}" || exit 1

# Update Ubuntu release list
regex="Ubuntu ([0-9]{2}\.[0-9]{2})(\.[0-9]+)? (LTS )?\(([A-Z][a-z]+) [A-Z][a-z]+\)"
temp[rlist]=$(mktemp)

grep_web "${UBUNTU_RELEASES_MIRROR}/HEADER.html" "${regex}" | while read -r line; do
	if [[ "${line}" =~ ${regex} ]]; then
		version="${BASH_REMATCH[1]}"
		full_version="${version}${BASH_REMATCH[2]}"
		[[ "${BASH_REMATCH[3]}" != "LTS " ]]
		support=$?
		codename="${BASH_REMATCH[4],,}"
		echo -e "${version}\t${full_version}\t${support}\t${codename}"
	fi
done > "${temp[rlist]}"

if [[ "${PIPESTATUS[0]}" == 0 && "$?" == 0 ]]; then
	mv "${temp[rlist]}" "release-list"
fi

# Update LiveCD
while read -r version full_version support codename; do
	for arch in amd64 i386; do
		# Only desktop/live-server variants support casper boot
		for variant in desktop live-server; do
			iso="ubuntu-${full_version}-${variant}-${arch}.iso"
			url="${UBUNTU_RELEASES_MIRROR}/${version}/${iso}"
			target="${codename}_${full_version}_${variant}_${arch}"

			url_check "${url}" || continue

			if [[ -d "${target}" ]]; then
				echo "Already exists: ${target}"
			else
				echo "Extracting ${url} to ${target}"
				net_extract "${url}" "${target}"
			fi
		done
	done
done < "release-list"

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
