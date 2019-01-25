#!/bin/bash

declare -Ag temp
cleanup_temp() {
	for key in "${!temp[@]}"; do
		echo "Clean up: ${temp[${key}]}"
		rm -rf -- "${temp[${key}]}"
	done
}
trap 'cleanup_temp' EXIT

panick() {
	local mesg str
	mesg=$1 && shift
	str=$(printf "==> ERROR: ${mesg}\n" "$@")
	echo "${str}" >&2
	exit 1
}

url2grub() {
	local url="$1"
	local url_regex='^(http|tftp)://([^/]+)(/.*)?$'
	if [[ "${url}" =~ ${url_regex} ]]; then
		local protocol="${BASH_REMATCH[1]}"
		local host="${BASH_REMATCH[2]}"
		local path="${BASH_REMATCH[3]}"
		echo "(${protocol},${host})${path}"
	fi
}

net_extract() {
	local url target workdir
	url="$1"
	target="$2"
	workdir=$(dirname "${target}")
	mkdir -p "${workdir}"

	id="net_extract_${RANDOM}"
	temp[${id}]=$(mktemp -d -p "${workdir}" .tmp.XXXXXXXX) || return 1

	curl -fsL "${url}" | bsdtar -x -f - -C "${temp[${id}]}"

	if [[ "${PIPESTATUS[0]}" == 0 && "$?" == 0 ]]; then
		chmod 755 "${temp[${id}]}"
		[[ -d "${target}" ]] && mv "${target}" "${target}.bak"
		mv "${temp[${id}]}" "${target}"
	else
		echo "Download failed"
		rm -rf "${temp[${id}]}"
		return 1
	fi
}

url_check() {
	curl -fI "$1" >/dev/null 2>&1
}

grep_web() {
	local url="$1"
	local regex="$2"
	curl -fsL "${url}" | grep -Po "${regex}" | sort -ur
	[[ "${PIPESTATUS[0]}" == 0 ]]
}

grub_menu_sep() {
	cat <<-EOF
		menuentry '$1' {
		  true
		}
	EOF
}

grub_linux_entry() {
	local title="$1"
	local kernel="$2"
	local initrd="$3"
	local param="$4"
	cat <<-EOF
		menuentry '${title}' {
		  echo 'Loading kernel...'
		  linux ${kernel} ${param}
		  echo 'Loading initial ramdisk...'
		  initrd ${initrd}
		}
	EOF
}

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
