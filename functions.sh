url2grub() {
	url="$1"
	url_regex='^(http|tftp)://([^/]+)(/.*)?$'
	if [[ "$url" =~ $url_regex ]]; then
		protocol="${BASH_REMATCH[1]}"
		host="${BASH_REMATCH[2]}"
		path="${BASH_REMATCH[3]}"
		echo "($protocol,$host)/$path"
	fi
}
# vim: set ts=4 sw=4 sts=4 noexpandtab nosta:
