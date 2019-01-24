#!/bin/bash
#root: debian

source functions.sh
cd "$LOCAL_PATH"

temp[rlist]=$(mktemp)
count=0
status_list=( unstable testing stable oldstable oldoldstable )

for status in "${status_list[@]}"; do
	while read line; do
		IFS=": " read key value <<< "$line"
		if [[ "$key" == Version ]]; then
			version="$value"
		elif [[ "$key" == Codename ]]; then
			echo -e "$value\t$status\t$version" >> "$temp[rlist]"
			count=$((count+1))
			break
		fi
	done < <(curl -fsL "$DEBIAN_MIRROR/dists/$status/Release")
done

if (( "$count" == "${#status_list[@]}" )); then
	mv "$temp[rlist]" "release-list"
else
	panick "Failed to update Debian version list"
fi

# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
