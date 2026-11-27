#!/bin/bash
#root: ubuntu

set -eo pipefail
source functions.sh
cd "${LOCAL_PATH}" || exit 1

temp[preseed]=$(mktemp)
cat > "${temp[preseed]}" <<- EOF && install -m644 "${temp[preseed]}" preseed.txt
	d-i mirror/country string manual
	d-i mirror/http/hostname string $(cut -d/ -f3 <<< "${DEBIAN_MIRROR}")
	d-i mirror/http/directory string /$(cut -d/ -f4- <<< "${DEBIAN_MIRROR}")
	d-i mirror/http/proxy string
EOF

# The mirror publishes separate Simple Streams catalogs for desktop and server ISOs.
temp[work]=$(mktemp -d .prepare.XXXXXXXX)
work=${temp[work]}
for product in ubuntu ubuntu-server; do
	curl -fLsS "${UBUNTU_RELEASES_MIRROR}/streams/v1/com.ubuntu.releases:${product}.json" -o "${work}/${product}.json"
done

jq -er '
	.products[] | select(.image_type == "desktop" or .image_type == "live-server" or .image_type == "server")
	| [.version, (.release_title | split(" ")[0]), (if .release_title | endswith(" LTS") then 1 else 0 end), .release]
	| @tsv
' "${work}"/ubuntu*.json | sort -u -k1,1Vr > "${work}/release-list"
mv "${work}/release-list" release-list

jq -er '
	.products[] | select(.image_type == "desktop" or .image_type == "live-server")
	| select(.arch == "amd64" or .arch == "i386")
	| select((.version | split(".")[0] | tonumber) >= 20)
	| (.versions | to_entries | max_by(.key | split(".") | map(tonumber))) as $latest
	| [.release, $latest.key, .image_type, .arch, $latest.value.items.iso.path, $latest.value.items.iso.sha256]
	| @tsv
' "${work}"/ubuntu*.json > "${work}/images"

while read -r codename version variant arch path sha256; do
	target="${codename}_${version}_${variant}_${arch}"
	if [[ -d "${target}/http" ]]; then
		continue
	fi
	echo "Preparing ${path}"
	mkdir "${work}/http"
	iso="${work}/http/install.iso"
	curl -fLsS "${UBUNTU_RELEASES_MIRROR}/${path}" -o "${iso}"
	printf '%s  %s\n' "${sha256}" "${iso}" | sha256sum --check
	bsdtar -C "${work}/http" -xf "${iso}" casper/vmlinuz casper/initrd
	mkdir -p "${target}"
	mv -T "${work}/http" "${target}/http"
done < "${work}/images"

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
