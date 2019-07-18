#!/bin/bash

usage() {
	echo "Usage: $0 -f <string>" 1>&2;
	exit 1;
}

while getopts ":e:l:" o; do
    case "${o}" in
        f)
            f="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "Generating Creators vocabulary.";
catmandu import CSV to DBI --data_source dbi:SQLite:/tmp/import.CREATORS_UTF8.sqlite < "$f"