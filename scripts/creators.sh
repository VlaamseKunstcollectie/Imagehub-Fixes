#!/bin/bash

#
# 1. Check out https://github.com/VlaamseKunstcollectie/Authority-Files
# 2. Check out https://github.com/VlaamseKunstcollectie/Imagehub-Fixes
# 3. chmod +x creators.sh
# 4. ./creators.sh -e ../../Authority-Files/CREATORS_UTF8.csv
#

usage() { echo "Usage: $0 [-e <string>]" 1>&2; exit 1; }

while getopts ":e:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${e}" ]; then
    usage
fi

echo "Generating Creators vocabulary.";
catmandu import CSV to DBI --data_source dbi:SQLite:/tmp/import.CREATORS_UTF8.sqlite < $e