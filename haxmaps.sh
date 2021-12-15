#!/bin/bash

declare OPT_SEARCH=false
declare OPT_GET=false
declare OPT_DOWNLOAD=false
declare OPT_JSON=false

declare QUERY=''
declare GETID=''

function main() {
	parsed_args=$(getopt -o s:g:djh -l search:,get:,download,json,help -n 'haxmaps' -- "$@")
	getopt_exit_code=$?

	if [ $getopt_exit_code -ne 0  ] ; then
		exit 1
	fi

	eval set -- "$parsed_args" 

	while :; do
		case "$1" in
			-h | --help ) show_help; exit 1 ;;
			-s | --search ) OPT_SEARCH=true; QUERY="$2"; shift 2 ;;
			-d | --download ) OPT_DOWNLOAD=true; shift ;;
			-j | --json ) OPT_JSON=true; shift ;;
			-g | --get ) OPT_GET=true; GETID="$2"; shift 2 ;;
			-- ) shift; break ;;
			* ) break ;;
		esac
	done

	if ! $OPT_SEARCH && ! $OPT_GET ; then
		show_help
		exit 1
	fi

	if $OPT_GET ; then
		download "$GETID" > "$GETID.hbs"
		exit 0
	fi

	if $OPT_SEARCH ; then
		if $OPT_DOWNLOAD ; then
			search "$QUERY" | jq --raw-output '.results[].id' | (
				while read id; do
					download "$id" > "$id.hbs"
				done
			)
		elif $OPT_JSON ; then
			search "$QUERY"
		else
			printf "%s\t\t%s\n" "ID" "Map name"
			search "$QUERY" | jq --raw-output '.results[] | "\(.id)\t\t\(.name)" '
		fi
		exit 0
	fi

	show_help
	exit 1
}

function err() {
	printf "haxmaps: %s\n" "$@" >&2
	exit 1
}

function show_help() {
	echo Usage: haxmaps [ -h ] [ [ -jd ] -s search_query ] [ -g haxmap_id ]
	echo Options are:
	echo '     -s | --search                  search in the map database and show the results in readable format'
	echo '     -g | --get                     download a specific map by id'
	echo '     -d | --download                use with the search flag to download all the maps'
	echo '     -j | --json                    use with the search flag to set the output format to json'
	echo '     -h | --help                    display this message and exit'
}

download() {
	curl -s "https://haxmaps.com/dl/$1"
}

search() {
	results=$(curl -s --data-urlencode "queryString=$1" https://haxmaps.com/hb/rpc | grep -Po '<li.*?</li>')
	
	if [ $(echo "$results" | wc -c) -lt 5 ] ; then
		echo '{ "results": [] }'
		exit 0
	fi

	length=$(echo "$results" | wc -l)

	echo "$results" | (
		index=0
		echo -n '{ "results": ['
		while read line; do
			map_id=$(echo "$line" | grep -Po 'https://haxmaps.com/map/\K[0-9]+')
			map_name=$(echo "$line" | grep -Po '</b>\K.*?(?=</li>)' | xargs)
			echo -n "{ \"name\": \"$map_name\", \"id\": \"$map_id\" }"
			if [ $index -ne $((length-1)) ] ; then
				echo -n ','
			fi
			index=$((index+1))
		done;
		echo -n ']}'
	)
}

main "$@"
