#!/bin/bash
#root: debian

source functions.sh
cd "${LOCAL_PATH}" || exit 1

temp[preseed]=$(mktemp)
cat > "${temp[preseed]}" <<- EOF && install -m644 "${temp[preseed]}" preseed.txt
	d-i mirror/country string manual
	d-i mirror/http/hostname string $(cut -d/ -f3 <<< "${DEBIAN_MIRROR}")
	d-i mirror/http/directory string /$(cut -d/ -f4- <<< "${DEBIAN_MIRROR}")
	d-i mirror/http/proxy string
EOF

temp[rlist]=$(mktemp)
count=0
status_list=(unstable testing stable oldstable oldoldstable)

for status in "${status_list[@]}"; do
	while read -r line; do
		IFS=": " read -r key value <<< "${line}"
		if [[ "${key}" == Version ]]; then
			version="${value}"
		elif [[ "${key}" == Codename ]]; then
			echo -e "${value}\t${status}\t${version}" >> "${temp[rlist]}"
			count=$((count + 1))
			break
		fi
	done < <(curl -fsL "${DEBIAN_MIRROR}/dists/${status}/Release")
done

if (("${count}" == "${#status_list[@]}")); then
	mv "${temp[rlist]}" "release-list"
else
	panick "Failed to update Debian version list"
fi

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
