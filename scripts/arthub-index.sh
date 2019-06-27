#/bin/bash

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

# Fetch data from the OAI endpoint

echo "Fetching data"
catmandu convert OAI --url $e --handler lido to JSON --fix ../fixes/datahub-oai-to-blacklight-solr.fix > /tmp/bulk.json

# Fetch XML raw data from the OAI endpoint and add it to the JSON blob.

echo "Fetching XML"
perl process.pl $e > /tmp/bulk_raw.json

echo "]" >> /tmp/bulk_raw.json

# Cleans out the dataset. All records without an 'id' field are purged.

cp /tmp/bulk_raw.json /tmp/bulk_unfiltered.json
catmandu convert JSON to JSON --fix "select all_match(id, '.*\S.*')" < /tmp/bulk_unfiltered.json > /tmp/bulk_raw.json
rm /tmp/bulk_unfiltered.json

# Remove the index

# bundle exec rake jetty:stop
# rm -r jetty/solr/blacklight-core/data/*
# bundle exec rake jetty:start

# Push data to the index

echo "Pushing data"
dhconveyor index -p ../pipelines/arthub.ini -v