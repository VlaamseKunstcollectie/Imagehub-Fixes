#!/bin/bash
set -e

# ETL 2-3 & ETL 5

(
  cd /srv/imagehub/imagehub ;
  ./app/console app:fill-resourcespace > /dev/null 2>&1 ;
  ./app/console app:generate-manifests > /dev/null 2>&1
)

# Update of authority files (updated CREATORS file?)

(
  cd /srv/imagehub/authority-files ;
  git pull
)

# ETL 6

(
  cd /srv/imagehub/imagehub-fixes/scripts ;
  ./creators.sh -e /srv/imagehub/authority-files/CREATORS_UTF8.csv > /dev/null 2>&1 ;
  ./arthub-index.sh -e https://datahub.iiif.vlaamsekunstcollectie.be/oai -l ../fixes/datahub-oai-to-blacklight-solr-en.fix > /dev/null 2>&1 ;
  ./arthub-index.sh -e https://datahub.iiif.vlaamsekunstcollectie.be/oai -l ../fixes/datahub-oai-to-blacklight-solr-nl.fix > /dev/null 2>&1
)

# keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
# trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT