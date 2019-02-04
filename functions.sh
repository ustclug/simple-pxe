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
	local url code

	url="$1" && shift
	code=$(curl -sIL -o /dev/null -w "%{http_code}" "${url}") || return 1

	(( code < 400 )) && return 0
	for white in "$@"; do
		(( code == white )) && return 0
	done

	return 1
}

grep_web() {
	local url="$1"
	local regex="$2"
	curl -fsL "${url}" | grep -Po "${regex}" | sort -uVr
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

grub_option() {
	local var desc index title

	var="$1" && shift
	desc="$1" && shift

	cat <<- EOF
		if [ -z "\$${var}_INDEX" ]; then
		  set ${var}='$1'
		  set ${var}_DNAME='$2'
		  set ${var}_INDEX=0
		fi

		submenu "[option] ${desc} = \$${var}_DNAME" {
		  menuentry '${desc}:' {
		    export ${var}
		    export ${var}_DNAME
		    export ${var}_INDEX
		    configfile ${PXE_MENU_URL}
		  }
	EOF

	index=0
	while (("$#" >= 3)); do
		title="> $2"
		[[ -n "$3" ]] && title="${title}: $3"

		cat <<-EOF
			  menuentry '${title}' {
			    set ${var}='$1'
			    set ${var}_DNAME='$2'
			    set ${var}_INDEX=${index}
			    export ${var}
			    export ${var}_DNAME
			    export ${var}_INDEX
			    configfile ${PXE_MENU_URL}
			  }
		EOF

		shift 3
		index=$((index+1))
	done

	echo "}"
}

grub_mirror_selector() {
	local grub_var="$1" && shift

	declare -a buf
	for url in "$@"; do
		buf=("${buf[@]}" "${url}" "${url}" "")
	done

	grub_option "${grub_var}" "Mirror URL" "${buf[@]}"

	cat <<-EOF
		regexp \\
		--set=1:mirror_protocol \\
		--set=2:mirror_host \\
		--set=3:mirror_path \\
		'^([^:]+)://([^/]+)(/.*)\$' "\$${grub_var}"
	EOF
}

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
